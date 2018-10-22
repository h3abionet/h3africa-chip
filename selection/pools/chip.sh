#!/bin/bash
#PBS -N bead-select
#PBS -l procs=1,walltime=100:00:00,mem=7GB
#PBS -q WitsLong   
#PBS -t 0-1024




hostname

cd  /spaces/scott/chip/pool_selection/
run=${PBS_ARRAYID}
/usr/bin/time  python pool_select.py --input all.cpickle --label S${LABEL} --bad badscore60.lst --requests extra.lst,req_func_u.scores --factor 1.5 $run 10 18
