#!/usr/bin/env python

from __future__ import print_function

import csv
import glob
import gzip
import os
import cPickle as pickle
import random
import re
import sys
from subprocess import check_output
import multiprocessing
import argparse


# Given a directory with files with MAFs of the different groups, produce a pickle object
# which has for every SNP the count of the number of groups in which the SNP has 
# a MAF of a givent cut-off. If the group has at least 90 members then a MAF of args.maf
# is used -- if less, we increase the MAF cut off upwards to ensure wew are picking
# a reasonable signal

if len(sys.argv)==1:
    sys.argv="pgetfreqs.py $fdir maf_tbl.cpickle".split()


def parseArguments():
    parser = argparse.ArgumentParser(description='Produce pickle object with frequencies.')
    parser.add_argument("fdir",action='store',\
                   help="directory where frequences found")
    parser.add_argument("outf",action='store',\
                   help="name of output file")
    parser.add_argument('--maf', dest='maf', type=float, action='store',\
                   default = 0.04,help="frequency cut off")
    args = parser.parse_args()
    return args


args = parseArguments()

pools = {}
contents=set()

def annotatePool(f):
    total=0
    pname = re.sub(".*/","",f)
    for line in open(f):
        snp=line.rstrip()
        contents.add(snp.replace("_",":"))
            

def annotatePools(direc):
    innerdirs = glob.glob("%s/*"%direc)
    for d in innerdirs:
        fpools = glob.glob("%s/*"%d)
        for f in fpools:
            annotatePool(f)


def getFreq(grouptable,group,freqf):
    f = open(freqf)
    header=f.readline()
    is_plink = re.search(r" *CHR +SNP +A1 +A2 +MAF +NCHROBS",header)
    first=True
    #print(freqf)
    for line in f:
        #print(line)
        data=line.rstrip().strip().split()
        if is_plink:
            (snp,freq,obs)=(data[1],data[4],data[5])
            num=1.0*int(obs)/2
            if freq=="NA": freq=0
            freq=float(freq)
        else:
            chrom=data[0]
            pos=data[1]
            count=data[3]
            try:
               a1=data[5]
            except IndexEror:
                print(group,freqf,line)
            num=int(count)/2
            snp="%s:%s"%(chrom,pos)
            (a,af)=a1.split(":")
            freq=float(af)
        cut= args.maf if num>90 else (-0.28*num+25)/100
        m1 = min(1-cut,cut)
        m2 = max(1-cut,cut)
        if m1 <= freq <= m2:
            grouptable.add(snp)
        


def processGroup(q,fdir,group):
    grouptable=set()
    freqs = glob.glob("%s/%s/*.frq"%(fdir,group))
    #print(fdir,group,freqs)
    for freq in freqs:
        base=check_output("basename %s .frq"%freq,shell=True).rstrip()
        getFreq(grouptable,group,freq)
    q.put(grouptable)
    return
           


fdir = sys.argv[1] # Directory where the frequencies ae found
grouptable={}
snptable={}
jobs=[]
groups=["C1","E1","E2","N1","N2","S1","S2","W1","W2"]
q = multiprocessing.Queue()
for group in groups:
    grouptable[group] = set()
    process = multiprocessing.Process(target=processGroup,args=(q,fdir,group))
    jobs.append(process)

for j in jobs:
    j.start()

for g in groups:
    gtable = q.get()
    grouptable[g]=gtable
    for snp in gtable:
       snptable[snp]=snptable.get(snp,0)+1

for j in jobs:
    j.join()

        
fout=open(sys.argv[2],"w")
pickle.dump(snptable,fout,2)
fout.close()
