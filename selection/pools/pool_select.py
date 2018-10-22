#!/usr/bin/env python
from __future__ import print_function

import gc
import csv
import glob
import gzip
import os
import random
import re
import sys
import cPickle as pickle
import copy
import argparse

def parseArguments():
    parser = argparse.ArgumentParser(description='Find best selection')
    parser.add_argument('run', type=int, help='initial selection of pools (as bit set)')
    parser.add_argument('width', type=int, help='bit width to interpret run as')
    parser.add_argument('exhaustive', type=int, help='how many exhastive steps')
    parser.add_argument('--bad', dest='bad', action='store',
                   default = "", help='BAD snps which must be ignored')
    parser.add_argument('--requests', dest='requests', action='store',
                        default = "", help='comma separated file names of of extra SNPs')
    parser.add_argument('--unitcost', dest='unitcost', action='store_true',
                   default = False, help='use unit cost for all SNPs')
    parser.add_argument('--prechosen', dest='prechosen', action='store',
                   default = False, help='comma separated list of pools')
    parser.add_argument('--totalsize', dest='totalsize', action='store',
                   default = 1800000, help='total size of pools')
    parser.add_argument('--factor', dest='factor', action='store',
                   type=float, default = 1, help='factor to scale ** scores by')
    parser.add_argument('--input', dest='costfile',default="/tmp/want.pickle.gz",help="cost file as a pickled dictionary")
    parser.add_argument('--label', dest='label',default="",help="label for output")
    args = parser.parse_args()
    return args

args = parseArguments()
run = args.run
width = args.width
exhaust_depth=args.exhaustive


max_threshold = args.totalsize


def getPoolValue(poolf):
    contents=0
    for line in open(poolf):
        snp=line.rstrip()
        contents = contents + want.get(snp,0)
    return contents
            

def annotatePools(direc):
    with open("%s/poolsizes.csv"%direc) as f:
        for line in f:
            (base,size)=line.rstrip().split()
            fname = "%s.snps"%base
            pools[base]=(int(size),getPoolValue("%s/SNPLISTS/%s"%(direc,fname)))
    for fname in ["extra.snps","functional.snps"]:
       f = open(fname)
       for line in f:
           try:
              (snp,score)=line.rstrip().split()
              if want.has_key(snp):
                  want[snp]=max(float(score),want[snp])
              else:
                  want[snp]=float(score)
           except ValueError:
               continue

def stats0():
   for pname in pools.keys():
       (tot,con)=pools[pname]
       want_snps = len(con)
       print("%s\t%10d %10d %4.2f"%(pname,want_snps,tot,float(want_snps)/tot))
   print("\n\n\n\n")


def removeBadSNPs(fname):
   if not fname: return
   f=open("badscore60.snps")
   for line in f:
       snp=line.rstrip()
       if snp in want: del want[snp]
   f.close()


        
def getScores(f,want):
    for line in f:
        try:
            [snp,score]=line.rstrip().split()
        except ValueError:
            print ("Problem with input file -- no score "+line)
            sys.exit(1)
        want[snp]=max(float(score),want.get(snp,0))
    f.close()

def addRequests(fnames):
    if not fnames: return
    flist = fnames.split(',')
    for fn in flist:
        with open(fn) as f:
            getScores(f,want)



def stats1():
   for i in range(len(all_pools)):
       print("%8s"%all_pools[i],end="\t")
   print("")

def common(theta):
    for i in range(len(all_pools)):
        (tot,con)=pools[all_pools[i]]
        for j in range(i):
            (t2,c2)=pools[all_pools[j]]
            comm=len(con & c2)
            unique = len(con | c2)
            r1 = float(comm)/(tot+t2)
            r2 = float(unique)/(tot+t2)
            if r1 >= theta:
                print ("%5s %5s %4.2f %4.2f"%(all_pools[i],all_pools[j],r1,r2))



def pool_cmp(x,y):
    if x == y: return 0
    (t1,c1) = pools[x]
    (t2,c2) = pools[y]
    r1 = float(c1)/t1
    r2 = float(c2)/t2
    return int(100000*(r2-r1))


def getWantScores(fname):
   print ("Opening data",fname)
   if "gz" in fname:
       f = gzip.open(fname)
   else:
       f = open(fname)
   if "pickle" in args.costfile:
       want = pickle.load(f)
   else:
       want= {}
       getScores(f,want)
   return want



def getBest(available,ltot):
    best = 0
    bpool = ""
    for p in  available:
        (tot,con) = pools[p]
        if tot+ltot<=max_threshold:
            sc = float(con)/(tot+ltot)
            if sc > best:
                bpool = p
                best = sc
    return bpool

def greedy(pnames, chosen, tot,value):
    chosen = copy.deepcopy(chosen)
    if len(pnames)==0:
        return (0,chosen, tot, value)
    available = copy.deepcopy(pnames)
    while len(available)>0:
        next = getBest(available,tot)
        if not next: break
        available.remove(next)
        if next in chosen: continue
        chosen.append(next)
        value =  pools[next][1]
        tot   = tot + pools[next][0]
    return (0,chosen,tot,value)
    


def choose(pnames, chosen, tot,value,  d, exhaust_limit):
    if len(pnames)==0:
        return (0,chosen,tot,value)
    if  d>=exhaust_limit:
        return greedy(pnames, chosen, tot,value)
    (n2,c2,t2,sc2)=choose(pnames[1:],chosen, tot, value, d+1, exhaust_limit)
    chosen = copy.deepcopy(chosen)
    next = pnames[0]
    if next in chosen:
        return (2*n2,c2,t2,sc2)
    (ntot,nval) = pools[next]
    if tot+ntot > max_threshold:
        return (n2,c2,t2,sc2)
    chosen.append(next)
    (n1,c1,t1,sc1)=choose(pnames[1:],chosen, tot+ntot, value+nval,d+1,exhaust_limit)
    if sc1 > sc2:
        return (2*n1+1,c1,t1,sc1)
    else:
        return (2*n2,c2,t2,sc2)

def outputSNPs(fname,snps,score):
    f = open(fname,"w")
    for s in sorted(snps):
        if s in score:s="%s\t%d"%(s,int(score[s]))
        f.write("%s\n"%(s))
    f.close()

def showChosenSnps(run,chosen):
    snps   = []
    targets= []
    for p in chosen:
        with open("pools/SNPLISTS/%s.snps"%p) as f:
            for line in f:
                line=line.rstrip()
                snps.append(line)
                if line in want: targets.append(line)
    outputSNPs("chosen-%s%d.lst"%(args.label,run),snps,{})
    outputSNPs("chosen-%s%d.trg"%(args.label,run),targets,want)


def firstpath (init,d, chosen, pnames):
    tot = 0
    value=0
    for p in chosen:
        (c,v)= pools[p]
        if tot+c > max_threshold:
            break
        tot = tot + c
        value=value+v
    start=init
    powr=1
    this_choice=1
    for i in range(d):
        if pnames[i] in chosen: continue
        if  init % 2 == 1:
            chosen.append(pnames[i])
            this_choice=this_choice+powr
            (c,v)=pools[pnames[i]]
            if tot+c> max_threshold:
                break
            tot = tot + c
            value = value+v
        init=init/2
        powr=powr*2
    (n,ch,t,sc) = choose(pnames[d:],chosen,tot,value,0,exhaust_depth)
    print("Pools chosen: ",end="")
    for c in sorted(ch):
        print(c,end=" ")
    print("\nScore=%d\tTotal pool size=%d\tS=%s,%d SEED=%d\n"%(sc,t,start,n,n*2**width+start))
    return ch



want = getWantScores(args.costfile)
removeBadSNPs(args.bad)
addRequests(args.requests)
for snp in want.keys():
   want[snp]= 1 if args.unitcost else want[snp]**args.factor
pools = {}
annotatePools("pools")

all_pools = sorted(pools.keys(),key=lambda x : float(pools[x][1])/pools[x][0],reverse=True)
print (all_pools)

prechosen = args.prechosen.split(",")   if args.prechosen else []
chosen    = firstpath(run,width,prechosen,all_pools)
showChosenSnps(run,chosen)
