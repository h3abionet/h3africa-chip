

# Compares windows of imputation 
from __future__ import print_function

import os
from os import R_OK,access
from os.path import join
import sys
import re
import glob

import argparse


def parseArguments():
    parser = argparse.ArgumentParser(description='Check for for unbalanced windows.')
    parser.add_argument('--resultdir', dest='resultdir', action='store',\
                   default="/mnt/lustre/users/gbotha/h3a/team/ALL_CHIP_DATA/CHIP_RESULTS/EVALUATION_MAMANA/imputation_chip_design_h3a_2ref/Reports/",\
                   help='features')
    parser.add_argument('--comparator', dest='comparator', action='store',\
                   default = 2, type=int, help='which is the comparator')
    parser.add_argument("--reqdir",dest='reqdir',action='store',\
                   default="/mnt/lustre/users/gbotha/h3a/team/ALL_CHIP_DATA/CHIP_RESULTS/EVALUATION_MAMANA/PRESEL/",\
                   help="Directory where all the required SNPs can be found")
    parser.add_argument("--pops",dest='pops',action='store',\
                   default="BENIN,ETHIOPIA",\
                   help="Comma separated list of populations (prefix of fnames)")
    parser.add_argument("--template",dest='template',action='store',\
                   default="%d/%s_%d_cutoff0.8_Axiom_GW_PanAFR_na35__HumanOmni2-5__gtld-1219-gred__h3achip_2p5_final__hybrid-c_coverage_1Mb_chunk.csv",\
                   help="Template for the report files")
    parser.add_argument("--chipdir",dest='chipdir',action='store',\
                   default="/mnt/lustre/users/gbotha/h3a/team/ALL_CHIP_DATA/CHIP_RESULTS/EVALUATION_MAMANA/CANDIDATES",\
                   help="Directory where chips can be found")
    parser.add_argument("--chips",dest='chips',action='store',\
                   default="Axiom_GW_PanAFR_na35,HumanOmni2-5,gtld-1219-gred,h3achip_2p5_final,hybrid-c")
    parser.add_argument("--ind_margin",dest='ind_margin',action='store',\
                   default=0.3,type=float)
    parser.add_argument("--ove_margin",dest='ove_margin',action='store',\
                   default=0.8,type=float)
    parser.add_argument("--no_windows_without_candidates",dest="notemptywindows",action="store_true",default=False)
    args = parser.parse_args()
    return args



args=parseArguments()

req_files = glob.glob(join(args.reqdir,"*"))
comparator=args.comparator
template=args.template
num_windows=3000

pops = args.pops.split(",")


chip_dir = args.chipdir
chips = args.chips.split(",")
label = map (lambda x:x[:4],chips)
chsnps = map(lambda x : x+".snps", chips)
ind_margin=args.ind_margin
ove_margin=args.ove_margin

problems = []


#--- auxiliary routines to read SNP lists

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
      elif x == "MT": num=26
      else: num = 0
   return num

def snpSplit(x):
   try:
      (chrom,pos)=x.rstrip().split(":")
   except ValueError:
      # Patches which we ignore print ("**Problem with %s"%x)
      chrom=pos=0
   chrom = conv(chrom)
   pos   = int(pos)
   return (chrom,pos)



def getSNPs(fname):
    snp_list = [[] for chrom in range(27)]
    with open(fname) as f:
        for line in f:
            try:
                (chrom,pos)=snpSplit(line)
            except ValueError:
               print(fname)
               print(line)
               sys.exit(1)
            snp_list[chrom].append(pos)
        for chrom in range(0,27):
           snp_list[chrom].sort()
           #print(chrom,len(snp_list[chrom]))
    return snp_list

#--------------------------




# Given the name of an imputation file for a given population and SNP 
# return the performance for each window
def getComparator(fn):
   with open(fn) as f:
       f.readline()
       i=0
       curr_pop=[]
       for line in f:
           data = map(lambda x:float(x.split(";")[1]),\
                       re.findall("(\d+;\d+)",line))
           curr_pop.append(data[comparator])
           i=i+1
   return curr_pop


# for a given population, chip find the performance --
# compare to the comparator
def doPop(pop,fn,c,chip_stats,comp_stats,chip_stat):
   curr = []
   with open(fn) as f:
       g =  open("%s.split"%fn,"w")
       f.readline()
       last=1
       i=0
       for line in f:
           data = map(lambda x:float(x.split(";")[1]),\
                       re.findall("(\d+;\d+)",line))
           curr.append(data[c])
           chip_stat[i]=chip_stat[i][0]+data[c]
           if comp_stats[i]<data[c]*ind_margin:
              problems.append((i,pop))
              pass
           i=i+1
       g.close()


def get_result(pop):
   for chrom in range(1,23):
      fn = join(args.resultdir,template%(chrom,pop,chrom))
      if not access(fn,R_OK): 
          print("Can't open ",fn)
          continue
      with open(fn) as f:
         f.readline()
         for line in f:
            matches = map (lambda x : float(x.split(";")[1]),\
                           re.findall(r"(\d+;-?\d+\.?\d*)",line))
            if len(matches)==0: continue
            wcoord=map(lambda x: int(float(x)),re.split("[-,]",line)[0:3])
            yield (wcoord[0],wcoord[1],wcoord[2],matches)

         

# Compare the chip across all populations
def doChip(c,chip,chip_stats,coord):
    chip_stat =[0]*10000
    curr_pop =[0 for i in range(num_windows)]
    for pop in pops:
        comp_stats=[]
        curr_pop  =[]
        i = 0
        for (chrom,start,end,results) in get_result(pop):
           comp = results[comparator]
           curr = results[c]
           coord[i]=[chrom,start,end]
           #if coord[i][0]==16 and  coord[i][1]==9000000:
           #   print(pop,curr,*coord[i],sep="\t")
           if comp < ind_margin*curr and comp==min(results):
              problems.append((i,pop))
           chip_stat[i]=curr+chip_stat[i]
           i=i+1
    del(chip_stat[i:])
    for i, res in enumerate(chip_stat):
       chip_stat[i]=float(res)/len(pops)
    return chip_stat

def globalStats(chip_results):
   best=[0]*len(chip_results)
   for i in range(len(chip_results[0])):
       res=[]
       for result in chip_results:
          res.append(result[i])
       for k in range(len(res)):
          if res[k]==max(res): best[k]=best[k]+1
       if res[comparator]<ove_margin*max(res):
           problems.append((i,"OVERALL"))





def checkOther(r,other):
   # takes  the range r and finds overlaps in other
   # "other" could be a simple integer list or more complex
   [chrom,start,fin] = r
   i = 0
   j = len(other[chrom])
   while i<j:
      m = int((i+j)/2)
      if start<other[chrom][m]:
         j=m-1
      elif other[chrom][m]<start:
         i=m+1
      else:
          break
   num=0
   resps=[]
   while m<len(other[chrom]) and other[chrom][m]<start : m=m+1
   while m<len(other[chrom]) and other[chrom][m]<=fin:
      resps.append(other[chrom][m])
      num=num+1
      m = m+1
   return (num,chrom,resps)



def squash(problems):
   prev = coord[problems[0][0]]
   mproblems=[]
   total=0
   for i in range(1,len(problems)):
      curr = coord[problems[i][0]]
      if curr[0] != prev[0]:
         mproblems.append(prev)
         prev=curr
      elif prev[2]>curr[1]:
         prev=[prev[0],prev[1],curr[2]]
      else:
         mproblems.append(prev)
         prev=curr
   mproblems.append(prev)
   for prob in mproblems:
      total=total+prob[2]-prob[1]+1
   return total


def showProblem(i,pr,chips,snp_lists):
    nums=[]
    worst=best=0
    for c, chip in enumerate(chips):
       if chip_stats[c][i]>chip_stats[best][i]:
         best=c
       if chip_stats[c][i]<chip_stats[worst][i]:       
         worst=c
    if chip_stats[worst][i]<0: return
    if chip_stats[best][i]<0.1: return
    panels=[]
    for sl,snps in enumerate(snp_lists):
       (num,chrom,panel)=checkOther(coord[i],snps)
       free = len (set(panel)- required_snps[chrom])
       if sl==best: best_size=num
       if sl==comparator : cand_size=num
       nums.append(num)
       nums.append(free)
       panels.append(panel)
    if max(nums)==0 and args.notemptywindows: return
    delta=len(set(panels[best])-set(panels[comparator]))
    nums.append(delta)
    print(*coord[i],sep="\t",end="\t")
    print("%4.2f\t%4.2f\t%4.2f"%(chip_stats[worst][i],chip_stats[comparator][i],chip_stats[best][i]),end="\t")
    print(pr,label[best],sep="\t",end="\t")
    print(*nums,sep="\t",end="\t")
    isworst = "Y" if comparator==worst else "n"
    ratio=float(best_size)/cand_size if cand_size > 0 else -2
    print("%s\t%3.1f"%(isworst,ratio))


def getChipLists():
   # find the lists of the SNPs  in each chip
   snp_lists=[]
   for snps in chsnps:
      fn = join(chip_dir,snps)
      snp_lists.append(getSNPs(fn))
   return snp_lists

def getRequiredSNPs():
   # which are the fixed, required SNPs
  required_snps= [set() for chrom in range(27)]
  for req in req_files:
     for i in range(27):
        required_snps[i] = required_snps[i] | set(getSNPs(req)[i])
  return required_snps


chip_stats=[]
coord = {}
for c, chip in enumerate(chips):
   print("Chip ",c,chip)
   chip_stats.append(doChip(c,chip,chip_stats,coord))

globalStats(chip_stats)
problems.sort()

mproblems=[]
(pi,pr)=problems[0]
for (i,reason) in problems[1:]:
   if i==pi:
      if reason not in pr : pr  = pr+","+reason
   else:
      mproblems.append((pi,pr))
      pi=i
      pr=reason
mproblems.append((pi,pr))
problems=mproblems


snp_lists=getChipLists()
required_snps = getRequiredSNPs()

total = squash(problems)

header = "chr\tstart\tend\tworst_score\tcand_score\tbest_score\treason\tbest_chip"
for lab in label:
   header=header+"\t#%s\t%s-free"%(lab,lab)
header=header+"\tdelta\tWorst?\tRatio"

print(header)
for (i,reason) in problems:
   showProblem(i,reason,chips,snp_lists)



