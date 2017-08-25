#!/bin/bash

DEBUG=1

queue=H3A
config=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/sahgp/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config
bwa_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/sahgp/samblaster_marked_duplicates
flagstat_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/sahgp/flagstat
logs_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/sahgp/logs
logs_dir=$logs_dir"/flagstat."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

flagstat_job_ids='';
sample_count=1

bam_list=sahgp.flagstat.batch.bam_list


while read bam;
do
  file_name=$(basename $bam)
  sample_id=${file_name%%.bam} 
  flagstat_report=$flagstat_dir"/"${file_name%%.bam}.flagstat.report
  log_id="sahgp.flagstat."$sample_id"."$sample_count

  
  if [ $DEBUG -eq 1 ]
  then
    echo $logs_dir
    echo $flagstat_report
    echo $sample_id 
  else
    flagstat_qsub_cmd="qsub -N sahgp.fs.$sample_count -o $logs_dir/sahgp.flagstat.$sample_id.$sample_count.o -e $logs_dir/sahgp.flagstat.$sample_id.$sample_count.e -v config=$config,bam=$bam,flagstat_report=$flagstat_report,logs_dir=$logs_dir,log_id=$log_id -q $queue -l select=1:ncpus=$flagstat_threads:mem=${flagstat_mem}B -l walltime=$flagstat_walltime -M gerrit.botha@uct.ac.za -m abe sahgp.flagstat.single.sh"
    flagstat_job_id=`${flagstat_qsub_cmd}`

    echo ${flagstat_qsub_cmd} > $logs_dir/sahgp.flagstat.$sample_id.$sample_count.$flagstat_job_id.qsub
    cat sahgp.flagstat.single.sh > $logs_dir/sahgp.flagstat.$sample_id.$sample_count.$flagstat_job_id.sh
    cat $config > $logs_dir/sahgp.flagstat.$sample_id.$sample_count.$flagstat_job_id.config

    flagstat_job_ids=$flagstat_job_id":"$flagstat_job_ids
    echo "SAHGP flagstat: $flagstat_job_id"
    qalter -o $logs_dir/sahgp.flagstat.$sample_id.$sample_count.$flagstat_job_id.o $flagstat_job_id
    qalter -e $logs_dir/sahgp.flagstat.$sample_id.$sample_count.$flagstat_job_id.e $flagstat_job_id
  fi 

  (( sample_count+=1 ))
done < $bam_list
