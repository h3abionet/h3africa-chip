#!/bin/bash
queue=R807693
config=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/sahgp/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config
bwa_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/sahgp/bwa
duplicates_marked_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/sahgp/duplicates_marked
logs_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/sahgp/logs
logs_dir=$logs_dir/`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

mark_duplicates_job_ids='';
sample_count=1

for bam in `ls $bwa_dir/*.bam`
do
  file_name=$(basename $bam)
  sample_id=${file_name%%.bwa.sorted.bam} 
  marked_duplicates_bam=$duplicates_marked_dir"/"${file_name%%.bam}.duplicates_marked.bam
  mark_duplicates_qsub_cmd="qsub -N sahgp.md.$sample_count -o $logs_dir/sahgp.md.$sample_id.$sample_count.o -e $logs_dir/sahgp.md.$sample_id.$sample_count.e -v config=$config,bam=$bam,md_bam=$marked_duplicates_bam -q $queue -l select=1:ncpus=$mark_duplicates_threads:mem=${mark_duplicates_mem}B -l walltime=$mark_duplicates_walltime -M gerrit.botha@uct.ac.za -m abe sahgp.mark_duplicates.single.sh"
  mark_duplicates_job_id=`${mark_duplicates_qsub_cmd}`

  echo ${mark_duplicates_qsub_cmd} > $logs_dir/sahgp.mark_duplicates.$sample_id.$sample_count.$mark_duplicates_job_id.qsub
  cat sahgp.mark_duplicates.single.sh > $logs_dir/sahgp.mark_duplicates.$sample_id.$sample_count.$mark_duplicates_job_id.sh
  cat $config > $logs_dir/sahgp.mark_duplicates.$sample_id.$sample_count.$mark_duplicates_job_id.config

  mark_duplicates_job_ids=$mark_duplicates_job_id":"$mark_duplicates_job_ids
  echo "SAHGP mark duplicates: $mark_duplicates_job_id"
  qalter -o $logs_dir/sahgp.mark_duplicates.$sample_id.$sample_count.$mark_duplicates_job_id.o $mark_duplicates_job_id
  qalter -e $logs_dir/sahgp.mark_duplicates.$sample_id.$sample_count.$mark_duplicates_job_id.e $mark_duplicates_job_id
  (( sample_count+=1 ))
done

mark_duplicates_job_ids_length=${#mark_duplicates_job_ids}
(( mark_duplicates_job_ids_length-=1 ))
mark_duplicates_job_ids=${mark_duplicates_job_ids: 0: $mark_duplicates_job_ids_length}
