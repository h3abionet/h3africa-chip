#!/usr/bin/env


from __future__ import print_function

import re
import sys
import chiplib


import argparse


def parseArguments():
    parser = argparse.ArgumentParser(description='Check for for unbalanced windows.')
    parser.add_argument('--pools', dest='pools', action='store',\
                   default="/spaces/scott/chip/PRESEL/pools.srt", help='directory with custom complex')
    parser.add_argument('--gap', dest='gap', type=int, default=50)
    parser.add_argument("-o","--outf",action='store',default='stdout', help="name of output file")
    parser.add_argument("data",action='store')
    args = parser.parse_args()
    return args


def label(pool,x):
    snp = str(x)
    if x in pool: snp=snp+"P"
    return snp


def outputClashes(outf,chrom,snps,pool):
    lastg=-1
    delete=[]
    for i,snp in enumerate(snps):
        inpool = snp in pool
        if inpool:
            allpool = True
            j=i+1
            while allpool and j<len(snps) and snps[j]-snp<=args.gap:
                allpool =  snps[j] in pool
                j=j+1
            if allpool:
                j=i-1
                while allpool and j>=0 and snp-snps[j]<=args.gap:
                    allpool =  snps[j] in pool
                    j=j-1
            if allpool:
                #print("Should Deleting ",i,snps[i])
                delete.append(snps[i])
    for s in delete:
        snps.remove(s)
    outf.write("%d:%s"%(chrom,label(pool,snps[0])))
    last=snps[0]
    for snp in snps[1:]:
        if snp-last>args.gap:
            outf.write("\n")
        else:
            outf.write(" - ")
        outf.write("%d:%s"%(chrom,label(pool,snp)))
        last=snp
    outf.write("\n")
        
            

                
            



def checkChrom(outf,chrom,chip,pool):
   pool=set(pool)
   chip.sort()
   if len(chip)==0: 
       print("No SNPs in ",chrom)
       return
   curr = [chip[0]]
   for snp in chip[1:]:
      if snp - curr[-1] < args.gap:
         curr.append(snp)
      else:
         #if 228404280 < snp < 228404320: print(2)
         if len(curr)>1:
             curr_set = set(curr)
             if len(curr_set & pool) == len(curr_set): 
                 curr=[snp]
                 continue
             outputClashes(outf,chrom,curr,pool)   
         curr=[snp]


args=parseArguments()
pools = chiplib.getSNPs(args.pools)
data  = chiplib.getSNPs(args.data)
outf = sys.stdout if args.outf=='stdout' else open(args.outf,"w")

for chrom in range(27):
   checkChrom(outf,chrom,data[chrom],pools[chrom])
outf.close()

