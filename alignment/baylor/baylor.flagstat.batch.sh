#!/bin/bash

DEBUG=0

queue=H3A
config=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/baylor/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config
flagstat_dir=$flagstat_dir
logs_dir=$logs_dir"/flagstat."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

sample_count=1

bam_list=baylor.flagstat.batch.bam_list

while read bam;
do
  file_name=$(basename $bam)
  sample_id=${file_name%%.bam} 
  flagstat_report=$flagstat_dir"/"${file_name%%.bam}.flagstat.report
  log_id="baylor.flagstat."$sample_id"."$sample_count

  
  if [ $DEBUG -eq 1 ]
  then
    echo $logs_dir
    echo $flagstat_report
    echo $sample_id 
  else
    pstracker_log_path=$logs_dir"/baylor.flagstat."$sample_id"."$sample_count
    flagstat_qsub_cmd="qsub -N blr.fs.$sample_count -o $logs_dir/baylor.flagstat.$sample_id.$sample_count.o -e $logs_dir/baylor.flagstat.$sample_id.$sample_count.e -v config=$config,bam=$bam,flagstat_report=$flagstat_report,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$flagstat_threads:mem=${flagstat_mem}B -l walltime=$flagstat_walltime -M $pbs_status_mailto -m abe baylor.flagstat.single.sh"
    flagstat_job_id=`${flagstat_qsub_cmd}`

    echo ${flagstat_qsub_cmd} > $logs_dir/baylor.flagstat.$sample_id.$sample_count.$flagstat_job_id.qsub
    cat baylor.flagstat.single.sh > $logs_dir/baylor.flagstat.$sample_id.$sample_count.$flagstat_job_id.sh
    cat $config > $logs_dir/baylor.flagstat.$sample_id.$sample_count.$flagstat_job_id.config

    echo "Baylor flagstat for $sample_id : $flagstat_job_id"
    qalter -o $logs_dir/baylor.flagstat.$sample_id.$sample_count.$flagstat_job_id.o $flagstat_job_id
    qalter -e $logs_dir/baylor.flagstat.$sample_id.$sample_count.$flagstat_job_id.e $flagstat_job_id
  fi 

  (( sample_count+=1 ))
done < $bam_list
