from __future__ import print_function


import sys
import re
import glob
import os.path
import multiprocessing
import random
import bisect
import cPickle

gap=125   #R2-02  125/65
gap2_margin=65
import argparse


def parseArguments():
    parser = argparse.ArgumentParser(description='Check for for unbalanced windows.')
    parser.add_argument('--good_snpsd', dest='good', action='store',\
                   default = "GOOD",help="Directory with good snps")
    parser.add_argument('--bad_snp', dest='bad_f', action='store',\
                   default = "/spaces/scott/chip/auxdata/bad.pickle",help="Directory with good snps")
    parser.add_argument('--twobeadsnps', dest='twobeadf', action='store',\
                   default="/spaces/scott/chip/auxdata/all2.pickle", help='file of SNPs that require two beads')
    parser.add_argument('--preselect', dest='presel', action='store',\
                   default="/spaces/scott/chip/R3.presel", help='directory with custom complex')
    parser.add_argument("--haplodir",dest='haplodir',action='store',\
                   default="/spaces/scott/chip/GROUPED/",\
                   help="Directory PLINK haplo blocks file can be found")
    parser.add_argument("--pops",dest='pops',action='store',required=True,\
                   help="Comma separated list of populations (prefix of fnames)")
    parser.add_argument("--limit",dest='limit',action='store',type=int,default=888000,\
                   help="total cost of chip")
    parser.add_argument("--batch",dest='batch',action='store',type=int,default=20000,\
                   help="batch size in distribution")
    parser.add_argument("--exons",dest='exons',action='store',\
                   default="/global/chpdes/gerrit/prep_exonic_non_exonic_bead_pools/Homo_sapiens.GRCh37.87.range",\
                   help="File where exons can be foudn")
    parser.add_argument("outf",action='store',\
                   help="name of output file")
    args = parser.parse_args()
    return args

total_selected=0
args=parseArguments()
good_snps_d = args.good  # A directory with The SNPs with decent Illumina scores
pref        = args.presel  # Directory containing files with pre-selected SNPs
haplodir    = args.haplodir  # Directory containing PLINK blocks files
pops        = args.pops.split(",")  # comma-separated list (which in haplodir wanted)
exon_f     = args.exons
outf        = args.outf  # name of output file

limit      = args.limit  # How big the CHIP
batch      =  args.batch   # In round robin phase how many are allocated
num_threads=32

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


def getPools(fn,snp_sel,selected):
   cost=0
   print("Reading in pools")
   with open(fn) as f: 
      for line in f:
         m=re.search(r"(.*):(\d+).*",line)
         if not m:
            print("Problem in file <%s> with line <%s>"%(fn, line))
            sys.exit(1)
         (chrom,pos) = m.group(1,2)
         chrom=conv(chrom)
         pos=int(pos)
         snp_sel[chrom][pos]=True
         selected[chrom].append(pos)
   for chrom in range(27):
       selected[chrom].sort()


def filterOut(source,notwanted):
    p1=p2=0
    curr=[]
    start=len(source)
    while p1<len(source) and p2<len(notwanted):
        if source[p1]<notwanted[p2]:
            curr.append(source[p1])
            p1 += 1
        elif source[p1]==notwanted[p2]:
            p1 +=1
            p2 +=1
        else:
            p2 +=1
    if p1<len(source):
        curr=curr+source[p1:]
    try:
        assert len(curr)<=start
    except AssertionError:
        sys.exit(start,len(notwanted),len(curr))
    return curr

def filterOut(source,notwanted):
    curr = sorted(list(set(source)-set(notwanted)))
    return curr



# Used to get pre-selected SNPs from one file
def getSNPs(fn,snp_sel,selected):
   cost=0
   # create a temporary data structure for this
   # this allows us to do this all in nlog in time at worst
   curr_snps=[[]for chrom in range(27)]
   print("Reading in ",fn)
   with open(fn) as f: 
      i=0
      old_chrom=old_pos=0
      for line in f:
         i += 1
         try:
             (chrom,pos) = line.split(":")
             chrom=conv(chrom)
             pos=int(pos)
         except ValueError:
             print("Error on line ",line)
             continue
           # is the snp bad or already chosen
         curr_snps[chrom].append(pos)
   # now filter
   print("Filtering bad and alreasy selected")
   for chrom in range(1,27):
       curr_snps[chrom].sort()       
       #curr_snps[chrom]=filterOut(curr_snps[chrom],bad_snp[chrom])
       curr_snps[chrom]=filterOut(curr_snps[chrom],selected[chrom])
   for chrom in range(1,27):
       print("Filtering bad margins",chrom)
       ptr=0
       for snp in curr_snps[chrom]:
           # is there a bad overlap
           ptr = bisect.bisect_left(selected[chrom],snp,ptr)
           #while ptr<len(selected[chrom])-1 and selected[chrom][ptr]<snp:
           #    ptr += 1
           ok = ptr<=2 or ptr>=len(selected[chrom])-2 or \
                (snp-selected[chrom][ptr-2]>gap or selected[chrom][ptr+1]-snp>gap) and\
                (snp-selected[chrom][ptr-3]>gap+gap2_margin and selected[chrom][ptr+2]-snp>gap+gap2_margin)
           if not ok: continue
           cost=(2 if snp in tbds[chrom] else 1)+cost
           snp_sel[chrom][snp]=True
           selected[chrom].insert(ptr,snp)
   return cost


def getPreparedPreselected(fn):
    selected=[[] for chrom in range(27)]
    f = open(fn)
    cost=0
    old_chrom=0
    for line in f:
         try:
             (chrom,pos) = line.split(":")
         except ValueError:
             print("Error on line ",line)
             continue
         chrom=conv(chrom)
         pos=int(pos)
         if chrom != old_chrom: 
             print(chrom)
             old_chrom=chrom
         cost=(2 if pos in tbds[chrom] else 1)+cost
         selected[chrom].append(pos)
    for chrom in range(27):
         print(chrom)
         selected[chrom].sort()
         snp_sel[chrom]=dict.fromkeys(selected[chrom],True)
         selected[chrom].append(pos)
    print("the cost is ",cost)
    return (selected,cost)


def getPreparedPreselected(fn):
    selected=cPickle.load(open("auxdata/R3.pickle"))
    cost=0
    old_chrom=0
    for chrom in range(27):
      for pos in selected[chrom]:
         if chrom != old_chrom: 
             print(chrom)
             old_chrom=chrom
         cost=(2 if pos in tbds[chrom] else 1)+cost
    for chrom in range(27):
         print(chrom)
         selected[chrom].sort()
         snp_sel[chrom]=dict.fromkeys(selected[chrom],True)
         selected[chrom].append(pos)
    print("the cost is ",cost)
    return (selected,cost)

def getPreselectedSNPs(pref):
    selected = [[]  for i in range(27) ]
    cost = 0
    getPools(os.path.join(pref,"pools.srt"),snp_sel,selected)
    fns = glob.glob(os.path.join(pref,"presel-pref*"))
    for fn in fns:
        print(fn)
        cost=cost+getSNPs(fn,snp_sel,selected)
    fns = glob.glob(os.path.join(pref,"presel-rest*"))
    for fn in fns:
        print(fn)
        cost=cost+getSNPs(fn,snp_sel,selected)
    print("Started with %d SNPs cost %d"%(total_selected,cost))
    return (selected,cost)

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
       old_chrom=0
       for line in f:
          i=i+1
          if i%100000==0:print(i) # Announce I'm still alive
          curr_block=line.rstrip()[1:].split()
          if curr_block:
             (chrom,pos)=snpSplit(curr_block[0])
             if old_chrom != chrom:
                 ptr=0
             curr_block = map(lambda x: int(x.split(":")[1]), curr_block)
             newload = dict.fromkeys(curr_block,0)
             for snp in curr_block:
                #ptr=bisect.bisect_left(selected[chrom],snp,pos)
                #inv[chrom][snp]=ptr
                snp_cover[chrom][snp]=len(curr_block)
             this_block.append((chrom, curr_block))
    random.shuffle(this_block) # shuffle so randomly ordered by chromosome
    # now sort by length of block
    slist=sorted(this_block,key=(lambda x:len(x[1])),reverse=True)
    if q: # Depends whether parallel nor not
       q.put(slist)
    else:
       return slist

def getBlocks(haplodir,pops):
    blocks=[]
    for pop in pops:
       slist=getPopBlock(False,haplodir,pop)
       blocks.append(slist)
    return blocks

        





def getChoice(candidates,toget):
    candidates.sort()
    indices=[]
    seg = toget+1
    for i in range(toget):
        indices.append(int((i+1)*len(candidates)/seg))
    return [candidates[i] for i in indices]


num_added=[0]*27
# tag a batch of haplobocks of one population
def tagSubBatch(q,p,selected,pblocks,curr_depth,cindex,thread):
   subbatch_size=batch/num_threads
   offset = (cindex+thread*subbatch_size)%len(pblocks)
   new_selected=[]
   for i in range(subbatch_size): # cover batch haplo blocks
        (chrom,curr_block)=pblocks[offset]
        choice = []
        biggest=0
        already=0
        # we go through the block to see if we need to tag the block
        # if so, choose that SNP that is in strong LD with the most 
        # populations across *all* grouops
        block_len=(curr_block[-1]-curr_block[0])
        quota=curr_depth+int(block_len/3000)
        lft=block_left=bisect.bisect_left(selected[chrom],curr_block[0]) # leftmost positio in current SNP list
        block_right=bisect.bisect_right(selected[chrom],curr_block[-1]) # rightmost position in current SNP list
        for i,snp in enumerate(curr_block):
           if snp_sel[chrom].has_key(snp):
              already=already+1
           elif snp not in bad_snp[chrom]:
               lft = bisect.bisect_left(selected[chrom],snp,lft,block_right)
               #lft=inv[chrom][snp]
               #lft = bisect.bisect_left(selected[chrom],snp,lft,max(len(selected[chrom]),lft+num_added[chrom]+1))
               ok =  (lft<=2 or  (snp-selected[lft-2]>gap or selected[lft+1]-snp>gap)) and\
                     (lft>=len(selected)-2  and (snp-selected[chrom][lft-3]>gap+gap2_margin and selected[chrom][lft+2]>gap+gap2_margin))
               if not ok: continue
               this_cover = snp_cover[chrom][snp]
               if  this_cover > biggest:
                 choice = [snp]
                 biggest=this_cover
               elif this_cover == biggest:
                 choice.append(snp)
        onebds = []
        exonsnps = []
        for snp in choice:
           if snp not in tbds[chrom] :  onebds.append(snp)
           if snp in is_exon[chrom]  :  exonsnps.append(snp)
        candidates = [snp for snp in exonsnps if snp in onebds]
        if (not candidates) and onebds: 
            candidates = onebds
        elif len(exonsnps)>0 : candidates = exonsnps
        else: 
            candidates = choice
        #if replace:
        #    print("Blocklen %d : choosing from %d : 1bd %d : exons %d : cand %d"%(len(curr_block),len(choice),len(onebds),len(exonsnps),len(candidates)))
        # Have we selected for this block and can we select more
        if already<quota  and len(candidates)>0:
           for the_choice in getChoice(candidates,quota-already):
               new_selected.append((chrom,the_choice))
        offset=(offset+1)%len(pblocks)
   #print("Blocklen %d : choosing from %d : 1bd %d : exons %d : cand %d "%(len(curr_block),len(choice),len(onebds),len(exonsnps),len(candidates)))
   q.put(new_selected)

def tagPop(selected,sel_cost,pblocks,p,curr_depth,last_at):
    global total_selected
    N=len(pblocks)
    cindex=last_at[p]
    q=multiprocessing.Queue()
    jobs=[]
    new_selected=[]
    for thread in range(num_threads):
       process = multiprocessing.\
           Process(target=tagSubBatch,args=(q,p,selected,pblocks,curr_depth[p],cindex,thread))
       jobs.append(process)
       process.start()
    for thread in range(num_threads):
       curr_sel=q.get()
       print(".... subbatch new is %d"%len(curr_sel))
       new_selected = new_selected+curr_sel
    print("Selected %d, last haplo %d at %d"%(len(new_selected),len(pblocks[(cindex+batch)%N][1]),(cindex+batch)%N))
    for j in jobs:
       j.join()
    if len(new_selected)==0:
       curr_depth[p]=curr_depth[p]+1
    for (chrom,pos) in set(new_selected):
        if snp_sel[chrom].has_key(pos):
            print("%d:$d already in "%(chrom,pos))
            continue
        lft = bisect.bisect_left(selected[chrom],pos)
        selected[chrom].insert(lft,pos)
        numadded[chrom] += 1
        LOG.write("%d:%d\n"%(chrom,pos))
        snp_sel[chrom][pos]=True
        total_selected=total_selected+1
        sel_cost = sel_cost+ (2 if pos in tbds[chrom] else 1)
        if sel_cost>limit: break
    last_at[p]=(cindex+batch)%N
    print(".... at position %d having chosen %d, cost %d "%(last_at[p],total_selected,sel_cost))
    return sel_cost

def getTagSNPs(selected,sel_cost,blocks):
    NUMP=len(pops)
    p=0
    curr_depth=[1]*NUMP
    last_at   =[0]*NUMP
    not_found=0
    while sel_cost <=limit:
       print("Working on population num %d, current selection is %d"%(p,sel_cost))
       before=sel_cost
       sel_cost = tagPop(selected,sel_cost,blocks[p],p,curr_depth,last_at)
       #if sel_cost: 
       #    print("Leaving after not able to select more")
       #    break   
       p=(p+1)%NUMP 



def computeStats(out,selected,blocks):
    eout=open("%s.exons"%out,"w")
    fout=open("%s.stats"%out,"w")
    histo={}
    total_cost=exon_count=0
    print("Added %d exonic snps"%added_exons)
    for chrom in range(1,27):
        for snp in selected[chrom]:
            if snp in is_exon[chrom] :
                eout.write("%s:%s\n"%(chrom,snp))
                exon_count=exon_count+1
            total_cost = total_cost + (2 if snp in tbds[chrom] else 1)
    for pblock in blocks:
       num_chosen = 0
       total      = 0
       for (chrom,curr_block) in pblock:
          count=covered=0
          for snp in curr_block:
             if snp_sel[chrom].has_key(snp): 
                covered=len(curr_block)
                count=count+1
          histo[count]=histo.get(count,0)+1
          total = total+len(curr_block)
          num_chosen = num_chosen+covered
       fout.write("Rate: %d\n"%(int(num_chosen*100/total)))
    fout.write("\nOverall cost=%d\n"%total_cost)
    fout.write("\nNumber of exonic snps=%d\n"%exon_count)
    fout.write("\nChromosome coverage:\n")
    for chrom in range(1,27):
       fout.write(" %s\t%d\n"%(chr2chr[chrom],len(selected[chrom])))
    keylist = list(histo.keys())
    fout.write("\n\nHistogram of coverage\n")
    for k in keylist:
       fout.write(" num[%d]=%4d\n"%(k,histo[k]))
    fout.close()
    eout.close()

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


inv = [{} for chrom in range(27)]
numadded = [0]*27

random.seed()
added_exons=0

LOG=open("log","w")
print("Reading bad SNPs")
bad_snp = getPickleSNPs(args.bad_f)
print("Getting exons")
exons = getExonRange(args.exons)
print("Getting two bead SNPs")
tbds = getPickleSNPs(args.twobeadf)
print("Reading preselected SNPs")
if ".presel" in pref:
    (selected,cost)=getPreparedPreselected(pref)
else:
    (selected,cost) = getPreselectedSNPs(pref)
    print("Writing preselected to disk")
    fout = open("%s.presel"%outf,"w")
    for chrom in range(1,27):
        for pos in sorted(selected[chrom]):
            fout.write("%s:%s\n"%(chr2chr[chrom],pos))
    fout.close()
print("Reading haploblocks")
blocks = getBlocks(haplodir,pops)
print("Determining exonic SNPs")
all_keys=[]
is_exon = getExonSNPs(selected,snp_cover,exons)

#print("Checking preselected against haploblocks")
#blocks = checkPreselected(selected,blocks) # Find out how many of current block chosen
print("Getting tag SNPs")
getTagSNPs(selected,cost,blocks)
print("Writing to disk")
fout = open("%s.sel"%outf,"w")
for chrom in range(1,27):
   for pos in sorted(selected[chrom]):
      fout.write("%s:%s\n"%(chr2chr[chrom],pos))
fout.close()
print("Ccomputing statistics....")
computeStats(outf,selected,blocks)
LOG.close()


