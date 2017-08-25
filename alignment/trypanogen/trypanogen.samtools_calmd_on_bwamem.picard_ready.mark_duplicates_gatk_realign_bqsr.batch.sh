#!/bin/bash
DEBUG=0

queue=H3A
config=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/trypanogen/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

samtools_calmd_dir=$samtools_calmd_dir
logs_dir=$logs_dir"/samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

# start pipeline
sample_count=1

bam_list=trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.batch.bam_list

while read bam;
do
  file_name=$(basename $bam);
  sample_id=${file_name%%.bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bqsr.bam}
  
  ## samtools calmd settings
  samtools_calmd_bam=$samtools_calmd_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bqsr.calmd.bam"
  samtools_calmd_bai=$samtools_calmd_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bqsr.calmd.bai"

  # First check if samtools calmd bai has been generated 
  if [ ! -f $samtools_calmd_bai ] 
  then 
    pstracker_log_path=$logs_dir"/trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr."$sample_id"."$sample_count  
    samtools_calmd_cmd="qsub -N tg.scmd.$sample_count -o $logs_dir/trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.$sample_id.$sample_count.o -e $logs_dir/trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.$sample_id.$sample_count.e -v config=$config,bam=$bam,samtools_calmd_bam=$samtools_calmd_bam,samtools_calmd_bai=$samtools_calmd_bai,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$samtools_calmd_threads:mem=${samtools_calmd_mem}B -l walltime=$samtools_calmd_walltime -M gerrit.botha@uct.ac.za -m abe trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.single.sh"
 
    if [ $DEBUG -eq 1 ]
    then
      echo $samtools_calmd_cmd
    else 
      samtools_calmd_job_id=`${samtools_calmd_cmd}`
      echo "SAHGP: $sample_id, samtools calmd: $samtools_calmd_cmd"
    
      echo ${samtools_calmd_cmd} > $logs_dir/trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.$sample_id.$sample_count.$samtools_calmd_job_id.qsub
      cat trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.single.sh > $logs_dir/trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.$sample_id.$sample_count.$samtools_calmd_job_id.sh
      cat $config > $logs_dir/trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.$sample_id.$sample_count.$samtools_calmd_job_id.config

      qalter -o $logs_dir/trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.$sample_id.$sample_count.$samtools_calmd_job_id.o $samtools_calmd_job_id
      qalter -e $logs_dir/trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.$sample_id.$sample_count.$samtools_calmd_job_id.e $samtools_calmd_job_id
    fi
  else
    echo "All BAMs for sample "$sample_id" have been created" 
  fi

  (( sample_count+=1 ))

done < $bam_list
