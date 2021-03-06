from __future__ import print_function


import sys
import re
import glob
import os.path
import multiprocessing
import random
import cPickle
import bisect

import argparse

gap=55

def parseArguments():
    parser = argparse.ArgumentParser(description='Check for for unbalanced windows.')
    parser.add_argument('--badf', dest='badf', action='store',\
                   default = "/spaces/scott/chip/auxdata/bad.pickle",help="Directory with good snps")
    parser.add_argument('--twobeadsnps', dest='twobeadf', action='store',\
                   default="/spaces/scott/chip/auxdata/all2.pickle", help='file of SNPs that require two beads')
    parser.add_argument('--preselect', dest='presel', action='store',\
                   default="PRESEL", help='directory with custom complex')
    parser.add_argument('--alt', dest='alt', action='store',\
                   default="alt", help='other option')
    parser.add_argument("--haplodir",dest='haplodir',action='store',\
                   default="/spaces/scott/chip/GROUPED/",\
                   help="Directory PLINK haplo blocks file can be found")
    parser.add_argument("--problems",dest='problems',action='store',\
                   help="problem window")
    parser.add_argument("--patchratio",dest='patchratio',action='store',type=float,default=1,\
                   help="what proportion of segmenets should be patched")
    parser.add_argument("--exons",dest='exons',action='store',\
                   default="/global/chpdes/gerrit/prep_exonic_non_exonic_bead_pools/Homo_sapiens.GRCh37.87.range",\
                   help="File where exons can be foudn")
    parser.add_argument("outf",action='store',\
                   help="name of output file")
    args = parser.parse_args()
    return args

total_selected=0
args=parseArguments()
pref        = args.presel  # Directory containing files with pre-selected SNPs
haplodir    = args.haplodir  # Directory containing PLINK blocks files
exon_f     = args.exons
outf        = args.outf  # name of output file

num_threads=10

#-------- key data structures used
# They are split by chromosome -- a dictionary per chromosome

# snp_cover[3][1789]  How many other SNPs is pos 1789 on chrom 3 in LD with
snp_cover=[{} for chrom in range(27)]

# snp_good[3][1789]  Has Illumina scored it good?
snp_good=[{} for chrom in range(27)]

# snp_sel[3][1789]  Are we selecting it?
snp_sel=[{} for chrom in range(27)]



#------ some auxiliary code

#             0  1   2   3   4  5    6   7   8  9
chrom_size=[ 10,260,260,210,200,190,180,170,160,150,\
            150,150,140,120,120,110,100, 90, 90, 80,\
             70, 60, 60,160,70,160,1]
chrom_size = map (lambda x : x*1000000,chrom_size)

chr2chr = map(str,range(0,27))
chr2chr[23]="X"
chr2chr[24]="Y"
chr2chr[25]="XY"
chr2chr[26]="MT"



def conv(x):
   try:
      num = int(x)
   except ValueError:
      if x == "X": num=23
      elif x == "Y": num=24
      elif x == "XY": num =25
      else: num=26
   return num

def binfind(selected,i,value,delta):   
   j=len(selected)-1
   m = int((i+j)/2)
   while i<j and selected[m]!=value:
      if selected[m]>value:
         i=m
      else:
         j=m
   return m

def extract(selected,small,big):
   l1=max(0,binfind(selected,0,small,-1))
   r1=min(len(selected),binfind(selected,l1,big,+1))
   return (l1,r1)


#-------------------- end of aux code


# Used to get pre-selected SNPs from one file
def getSNPs(sofar,fn):
   global total_selected
   cost=0
   with open(fn) as f: 
      for line in f:
         m=re.search(r"(.*):(\d+).*",line)
         if not m:
            print("Problem in file <%s> with line <%s>"%(fn, line))
            sys.exit(1)
         (chrom,pos) = m.group(1,2)
         chrom=conv(chrom)
         pos=int(pos)
         total_selected=total_selected+1
         cost=(2 if pos in tbds[chrom] else 1)+cost
         snp_sel[chrom][pos]=True
         sofar[chrom].append(pos)
   return cost

def getPreselectedSNPs(pref):
    fns = glob.glob(os.path.join(pref,"*"))
    selected = [[]  for i in range(27) ]
    cost = 0
    for fn in fns:
        cost=cost+getSNPs(selected,fn)
    for i,v in enumerate(selected):
       selected[i]=set(v)
    print("Started with %d SNPs cost %d"%(total_selected,cost))
    return (selected,cost)

def getTwoBeadSNPs(fn):
    tbds = [set()  for i in range(27) ]
    if not fn: return tbds
    with open(fn) as f: 
      for line in f:
         m=re.search(r"(.*):(\d+).*",line)
         if not m:
            print("Problem in file <%s> with line <%s>"%(fn, line))
            sys.exit(1)
         (chrom,pos) = m.group(1,2)
         chrom=conv(chrom)
         pos=int(pos)
         tbds[chrom].add(pos)
    return tbds

def getPickleSNPs(fn):
    f=open(fn)
    tbds=cPickle.load(f)
    f.close()
    for chrom in range(27):
        tbds[chrom]=set(tbds[chrom])
    return tbds
    
    
# Used to get the SNPs with good scores from one file
def parGetSNPs(q,fn):
   sofar=[[]  for i in range(27) ]
   with open(fn) as f: 
      for line in f:
         (chrom,pos) = line.rstrip().split(":")
         chrom=conv(chrom)
         pos=int(pos)
         sofar[chrom].append(pos)
   for i, r in enumerate(sofar):
      sofar[i]=set(r)
   q.put(sofar)

# Used to get the SNPs with good scores from a listt of files
# we split the scores file to parallelise to speed up this phase
def getGoodSNPs(good_snps_d):
   fns = glob.glob("%s/*"%good_snps_d)
   q = multiprocessing.Queue()
   jobs=[]
   for f in fns:
       process = multiprocessing.Process(target=parGetSNPs,args=(q,f))
       jobs.append(process)
       process.start()
   for f in fns:
      curr= q.get()
      for i, chrgood in enumerate(curr):
         for g in chrgood:
            snp_good[i][g]=True
   for j in jobs:
      j.join()



def snpSplit(x):
   try:
      (chrom,pos)=x.split(":")
   except ValueError:
      print ("**Problem with %s"%x)
      chrom=pos=0
   chrom = conv(chrom)
   pos   = int(pos)
   return (chrom,pos)

# read the haploblocks for one of the groups
def getPopBlock(q,haplodir,pop):
    this_block=[]
    with open("%s/%s.blocks"%(haplodir,pop)) as f:
       i=0
       for line in f:
          i=i+1
          if i%100000==0:print(i) # Announce I'm still alive
          curr_block=line.rstrip()[1:].split()
          if curr_block:
             (chrom,pos)=snpSplit(curr_block[0])
             curr_block = map(lambda x: int(x.split(":")[1]), curr_block)
             newload = dict.fromkeys(curr_block,0)
             for snp in curr_block:
                snp_cover[chrom][snp]=len(curr_block)
             this_block.append((chrom, curr_block))
    random.shuffle(this_block) # shuffle so randomly ordered by chromosome
    # now sort by length of block
    slist=sorted(this_block,key=(lambda x:len(x[1])),reverse=True)
    if q: # Depends whether parallel nor not
       q.put(slist)
    else:
       return slist


def getBlocks(haplodir):
    all_ranges=cPickle.load(open("/spaces/scott/chip/all_exon_ranges.cpickle"))
    return all_ranges



        

# We don't use this at the moment -- ignore
def checkPreselected(selected,all_blocks):
    for i, pop_block in enumerate(all_blocks):
        # for each block, find out how many have been selected
        # we store tuple (numselected, haploblock)
        for (chrom,block) in pop_block: 
           count = 0
           for snp in block:
              if snp_sel[chrom].get(snp):
                 count=count+1
    return answer


def getChoice(candidates,toget):
    candidates.sort()
    indices=[]
    seg = toget+1
    for i in range(toget):
        indices.append(int((i+1)*len(candidates)/seg))
    return [candidates[i] for i in indices]
    


seg_len=10000
num_segs=1000000/seg_len


def getAlternatives(chrom,pos,selected_c,alt_selected_c,blocks):
    # First we get t he list of alternatives
    alt_snps=set()
    (start,finish)=pos
    # Add all the SNPs in the alternate chip
    for choice in [alt_selected_c]:
        choice=sorted(list(choice))
        left = bisect.bisect_left(choice,start)
        right= bisect.bisect_right(choice,finish)
        alt_snps= alt_snps | set(choice[left:right])
    # Add all the SNPs in the hapbloblockf ile
    for b in blocks:
       blocks_c=b[chrom]
       i=0
       while i< len(blocks_c) and blocks_c[i][0] < start:
          i=i+1
       while i< len(blocks_c) and blocks_c[i][1] <= finish:
          alt_snps = alt_snps | set(blocks_c[i][2])
          i=i+1
    alt_snps=alt_snps-selected_c
    src=sorted(list(alt_snps))
    ptr=0
    for alt in src:
        ptr=bisect.bisect_left(selected_c,alt,ptr)
        ok = (ptr<=1 or alt-selected_c[ptr-1]>gap) and \
             (ptr>=len(selected_c)-1 or selected_c[ptr]-snp>gap) 
        if not ok or alt in tbds[chrom] or alt in bad_snps[chrom]:
             alt_snps.remove(alt)
    alt_snps=sorted(list(alt_snps))
    return alt_snps

def findPoorSegments(pos,selected_c,alt_snps):
    (start,finish)=pos
    # Now we order segments to see where our coverage is not good
    our_pos=bisect.bisect_left(selected_c,start)
    alt_pos=bisect.bisect_left(alt_snps,start)
    cover_ratio=[]
    for seg in range(1+(finish-start)/seg_len):
        our_num=0
        alt_num=1  # to avoid divide by zero 
        while alt_pos < len(alt_snps) and alt_snps[alt_pos] < min(finish,start+seg*seg_len):
            alt_num=alt_num+1
            alt_pos=alt_pos+1  # tbd duh -- clean up -- don't need alt_num and alt_pos
        if  alt_pos >= len(alt_snps): break
        while our_pos < len(selected_c) and selected_c[our_pos] < min(finish,start+seg*seg_len):
            our_num=our_num+1
            our_pos=our_pos+1
        print("SNPS in segment %d versus %d\n"%(our_num,alt_num))
        cover_ratio.append((float(our_num)/alt_num,seg))
    cover_ratio.sort()
    return cover_ratio

def getReplacements(pos,alt_snps,cover_ratio):
    new_ones=[]
    picked=tried=0
    (start,finish)=pos
    while picked < max(1,int((finish-start)*args.patchratio/seg_len)) and tried<len(cover_ratio):
        (ratio,seg)=cover_ratio[tried]
        alt_lft=bisect.bisect_left(alt_snps,start+seg*seg_len)
        alt_rgt=bisect.bisect_right(alt_snps,start+(seg+1)*seg_len)
        if alt_lft<alt_rgt:
            m = (alt_lft+alt_rgt)/2
            new_ones.append(alt_snps[m])
            picked=picked+1
        tried=tried+1
    print (new_ones)
    return new_ones

def  patchWindow(chrom,pos,selected_c,cost,alt_selected_c,blocks,new_selected_c):
    print("Window ",chrom,pos)
    alt_snps = getAlternatives(chrom,pos,selected_c,alt_selected_c,blocks)
    selected_c=sorted(list(selected_c))
    cover_ratio = findPoorSegments(pos,selected_c,alt_snps)
    new_ones = getReplacements(pos,alt_snps,cover_ratio)
    print("Added ", len(new_ones))
    new_selected_c.extend(new_ones)

    

def patchWindows(prob_f,selected,cost,alt_selected,blocks):
    print("Patching windows")
    new_selected = [[] for i in range(27)]
    with open(prob_f) as f: 
        for snp in f:
            try:
                [chrom,start]=re.split(r"[_:\s-]",snp.rstrip())
                finish=int(start)+1000000
                chrom=conv(chrom)
                pos  = (int(start),int(finish))
                patchWindow(chrom,pos,selected[chrom],cost,alt_selected[chrom],blocks,new_selected[chrom])
            except ValueError:
                print(snp)
    return new_selected


def getExonRange(fn):
    exons =  [ [] for chrom in range(27)]
    with open(fn) as f:
        for line in f:
           m = re.search("(\w+):(\d+)-(\d+)",line)
           if not m:
               sys.exit("can't match "+line)
           chrom=conv(m.group(1))
           exons[chrom].append((int(m.group(2)),int(m.group(3))))
    for chrom in range(1,27):
       exons[chrom].sort()
    return exons

def getExonSNPs(selected,snp_cover,exons):
    # determine which SNPs are exons
    is_exon=[ {} for chrom in range(27) ]
    for chrom in range(1,27):
        ex=0
        curr=[]
        curr=list(snp_cover[chrom].keys())+list(selected[chrom])
        curr.sort()
        for snp in curr:
           while ex < len(exons[chrom]) and snp > exons[chrom][ex][1]:
               ex=ex+1
           if ex >= len(exons[chrom]) : break
           if exons[chrom][ex][0]<=snp<=exons[chrom][ex][1]:
                is_exon[chrom][snp]=True
    return is_exon

def getExonRange(fn):
    exons =  [ [] for chrom in range(27)]
    with open(fn) as f:
        for line in f:
           m = re.search("(\w+):(\d+)-(\d+)",line)
           if not m:
               sys.exit("can't match "+line)
           chrom=conv(m.group(1))
           exons[chrom].append((int(m.group(2)),int(m.group(3))))
    for chrom in range(1,27):
       exons[chrom].sort()
    return exons


random.seed()
added_exons=0

LOG=open("log","w")
print("Reading haploblocks")
blocks = getBlocks(haplodir)
print("Getting exons")
exons = getExonRange(args.exons)
print("Getting two bead SNPs")
tbds = getPickleSNPs(args.twobeadf)
print("Reading alt SNPs")
(alt_selected,cost_alt) = getPreselectedSNPs(args.alt)
print("Reading selected SNPs")
(selected,cost) = getPreselectedSNPs(pref)
print("Reading bad SNPs")
bad_snps=cPickle.load(open(args.badf))
for chrom in range(27): bad_snps[chrom]=set(bad_snps[chrom])
all_keys=[]
is_exon = getExonSNPs(selected,snp_cover,exons)

#print("Checking preselected against haploblocks")
#blocks = checkPreselected(selected,blocks) # Find out how many of current block chosen
print("Getting tag SNPs")
new_selected = patchWindows(args.problems,selected,cost,alt_selected,blocks)
print("Writing to disk")
fout = open("%s.sel"%outf,"w")
for chrom in range(1,27):
   for pos in sorted(selected[chrom]):
      fout.write("%s:%s\n"%(chr2chr[chrom],pos))
   for pos in sorted(new_selected[chrom]):
      fout.write("%s:%s\n"%(chr2chr[chrom],pos))
fout.close()
LOG.close()


