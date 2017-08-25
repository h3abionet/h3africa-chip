#!/bin/bash
DEBUG=0

queue=H3A
config=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/baylor/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

verifybamid_dir=$verifybamid_dir
logs_dir=$logs_dir"/verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

# start pipeline
sample_count=1

bam_list=baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.batch.bam_list

while read bam;
do
  file_name=$(basename $bam);
  sample_id=${file_name%%.bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bqsr.calmd.bam}
  
  verifybamid_prefix=$verifybamid_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bqsr.calmd.verifyBamID"
  verifybamid_persample_stats=$verifybamid_prefix.selfSM

  # First check if samtools calmd bai has been generated 
  if [ ! -f $verifybamid_persample_stats ] 
  then 
    pstracker_log_path=$logs_dir"/baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd."$sample_id"."$sample_count  
    verifybamid_cmd="qsub -N blr.vbi.$sample_count -o $logs_dir/baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.$sample_id.$sample_count.o -e $logs_dir/baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.$sample_id.$sample_count.e -v config=$config,bam=$bam,verifybamid_prefix=$verifybamid_prefix,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$verifybamid_threads:mem=${verifybamid_mem}B -l walltime=$verifybamid_walltime -M gerrit.botha@uct.ac.za -m abe baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.single.sh"
 
    if [ $DEBUG -eq 1 ]
    then
      echo $verifybamid_cmd
    else 
      verifybamid_job_id=`${verifybamid_cmd}`
      echo "Baylor: $sample_id, verifybam id: $verifybamid_job_id"
    
      echo ${verifybamid_cmd} > $logs_dir/baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.$sample_id.$sample_count.$verifybamid_job_id.qsub
      cat baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.single.sh > $logs_dir/baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.$sample_id.$sample_count.$verifybamid_job_id.sh
      cat $config > $logs_dir/baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.$sample_id.$sample_count.$verifybamid_job_id.config

      qalter -o $logs_dir/baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.$sample_id.$sample_count.$verifybamid_job_id.o $verifybamid_job_id
      qalter -e $logs_dir/baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.$sample_id.$sample_count.$verifybamid_job_id.e $verifybamid_job_id
    fi
  else
    echo "All verifyBamId sample statistics for sample "$sample_id" have been created" 
  fi

  (( sample_count+=1 ))

done < $bam_list
