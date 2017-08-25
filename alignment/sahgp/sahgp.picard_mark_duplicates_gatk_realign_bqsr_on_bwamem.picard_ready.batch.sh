#!/bin/bash
DEBUG=0

queue=H3A
config=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/sahgp/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

picard_ready_dir=$picard_ready_dir
picard_marked_duplicates_dir=$picard_marked_duplicates_dir
gatk_local_realigned_dir=$gatk_local_realigned_dir
gatk_bqsr_dir=$gatk_bqsr_dir
logs_dir=$logs_dir"/picard_mark_duplicates_gatk_realign_bqsr_on_bwamem.picard_ready."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

# start pipeline
sample_count=1

bam_list=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/sahgp/sahgp.picard_mark_duplicates_gatk_realign_bqsr_on_bwamem.picard_ready.batch.bam_list

#for bam in `ls $picard_ready_dir/*.bwa.sorted.bam`;
while read bam;
do
  file_name=$(basename $bam);
  sample_id=${file_name%%.bwa.sorted.bam}

  ## Mark duplicates with Picard settings
  marked_duplicates_metrics=$picard_marked_duplicates_dir/$sample_id".bwa.sorted.picard_marked_duplicates.metrics"
  marked_duplicates_bam=$picard_marked_duplicates_dir/$sample_id".bwa.sorted.picard_marked_duplicates.bam"
  marked_duplicates_bai=$picard_marked_duplicates_dir/$sample_id".bwa.sorted.picard_marked_duplicates.bai"

  ## GATKs local realignment settings
  gatk_realign_list=$gatk_local_realigned_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.list"
  gatk_realigned_bam=$gatk_local_realigned_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.bam"
  gatk_local_realign_threads=$(( gatk_local_realign_data_threads*gatk_local_realign_cpu_threads_per_data_thread ))
  picard_mate_fixed_bam=$gatk_local_realigned_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bam"
  picard_mate_fixed_bai=$gatk_local_realigned_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bai"

 
  ## GATKs base quality score recalibration settings
  gatk_bqsr_table=$gatk_bqsr_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bqsr.table"
  gatk_bqsr_bam=$gatk_bqsr_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bqsr.bam"
  gatk_bqsr_bai=$gatk_bqsr_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bqsr.bai"
  gatk_bqsr_threads=$(( $gatk_bqsr_data_threads*$gatk_bqsr_cpu_threads_per_data_thread ))

  # First check if marked duplicate bai has been generated 
  if [ ! -f $marked_duplicates_bai ] 
  then 
    pstracker_log_path=$logs_dir"/sahgp.mark_duplicates.picard_sort_index_realign_recal_on_bwamem.picard_ready."$sample_id"."$sample_count  
    picard_mark_duplicates_qsub_cmd="qsub -N sahgp.pmd.$sample_count -o $logs_dir/sahgp.mark_duplicates.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.o -e $logs_dir/sahgp.mark_duplicates.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.e -v config=$config,bam=$bam,marked_duplicates_metrics=$marked_duplicates_metrics,marked_duplicates_bam=$marked_duplicates_bam,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$picard_mark_duplicates_threads:mem=${picard_mark_duplicates_mem}B -l walltime=$picard_mark_duplicates_walltime -M gerrit.botha@uct.ac.za -m abe sahgp.picard_mark_duplicates_on_bwamem.picard_ready.single.sh"
 
    if [ $DEBUG -eq 1 ]
    then
      echo $picard_mark_duplicates_qsub_cmd
    else 
      marked_duplicates_job_id=`${picard_mark_duplicates_qsub_cmd}`
      echo "SAHGP: $sample_id, Picard MarkDuplicates: $marked_duplicates_job_id"
    
      echo ${picard_mark_duplicates_qsub_cmd} > $logs_dir/sahgp.mark_duplicates.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$marked_duplicates_job_id.qsub
      cat sahgp.picard_mark_duplicates_on_bwamem.picard_ready.single.sh > $logs_dir/sahgp.mark_duplicates.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$marked_duplicates_job_id.sh
      cat $config > $logs_dir/sahgp.mark_duplicates.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$marked_duplicates_job_id.config

      qalter -o $logs_dir/sahgp.mark_duplicates.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$marked_duplicates_job_id.o $marked_duplicates_job_id
      qalter -e $logs_dir/sahgp.mark_duplicates.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$marked_duplicates_job_id.e $marked_duplicates_job_id
    fi
    
    pstracker_log_path=$logs_dir"/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready."$sample_id"."$sample_count  
    gatk_local_realign_qsub_cmd="qsub -W depend=afterok:$marked_duplicates_job_id -N sahgp.glr.$sample_count -o $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.o -e $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.e -v config=$config,bam=$marked_duplicates_bam,gatk_realign_list=$gatk_realign_list,gatk_realigned_bam=$gatk_realigned_bam,picard_mate_fixed_bam=$picard_mate_fixed_bam,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_local_realign_threads:mem=${gatk_local_realign_mem}B -l walltime=$gatk_local_realign_walltime -M gerrit.botha@uct.ac.za -m abe sahgp.gatk_local_realign_on_picard_marked_duplicates.bwamem.picard_ready.single.sh"
    
    if [ $DEBUG -eq 1 ]
    then
      echo $gatk_local_realign_qsub_cmd
    else
      gatk_local_realign_job_id=`${gatk_local_realign_qsub_cmd}`
      echo "SAHGP: $sample_id, GATK local realignment: $gatk_local_realign_job_id"
      echo ${gatk_local_realign_qsub_cmd} > $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_local_realign_job_id.qsub
      cat sahgp.gatk_local_realign_on_picard_marked_duplicates.bwamem.picard_ready.single.sh > $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_local_realign_job_id.sh
      cat $config > $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_local_realign_job_id.config

      qalter -o $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_local_realign_job_id.o $gatk_local_realign_job_id
      qalter -e $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_local_realign_job_id.e $gatk_local_realign_job_id
    fi

    pstracker_log_path=$logs_dir"/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready."$sample_id"."$sample_count  
    gatk_bqsr_qsub_cmd="qsub -W depend=afterok:$gatk_local_realign_job_id -N sahgp.gbr.$sample_count -o $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.o -e $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.e -v config=$config,bam=$picard_mate_fixed_bam,gatk_bqsr_table=$gatk_bqsr_table,gatk_bqsr_bam=$gatk_bqsr_bam,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_bqsr_threads:mem=${gatk_bqsr_mem}B -l walltime=$gatk_bqsr_walltime -M gerrit.botha@uct.ac.za -m abe sahgp.gatk_bqsr_on_gatk_local_realign.picard_marked_duplicates.bwamem.picard_ready.single.sh"

  
    if [ $DEBUG -eq 1 ]
    then
      echo $gatk_bqsr_qsub_cmd
    else
      gatk_bqsr_job_id=`${gatk_bqsr_qsub_cmd}`
      echo "SAHGP: $sample_id, GATK BQSR: $gatk_bqsr_job_id"
   
      echo ${gatk_bqsr_qsub_cmd} > $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.qsub
      cat sahgp.gatk_bqsr_on_gatk_local_realign.picard_marked_duplicates.bwamem.picard_ready.single.sh > $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.sh
      cat $config > $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.config
      qalter -o $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.o $gatk_bqsr_job_id
      qalter -e $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.e $gatk_bqsr_job_id
    fi
  # Check if Picard's fixed bam index has been created 
  elif [ ! -f $picard_mate_fixed_bai ]; 
  then
    pstracker_log_path=$logs_dir"/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready."$sample_id"."$sample_count  
    gatk_local_realign_qsub_cmd="qsub -N sahgp.glr.$sample_count -o $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.o -e $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.e -v config=$config,bam=$marked_duplicates_bam,gatk_realign_list=$gatk_realign_list,gatk_realigned_bam=$gatk_realigned_bam,picard_mate_fixed_bam=$picard_mate_fixed_bam,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_local_realign_threads:mem=${gatk_local_realign_mem}B -l walltime=$gatk_local_realign_walltime -M gerrit.botha@uct.ac.za -m abe sahgp.gatk_local_realign_on_picard_marked_duplicates.bwamem.picard_ready.single.sh"
  
    if [ $DEBUG -eq 1 ]
    then
      echo $gatk_local_realign_qsub_cmd
    else
      gatk_local_realign_job_id=`${gatk_local_realign_qsub_cmd}`
      echo "SAHGP: $sample_id, GATK local realignemnt: $gatk_local_realign_job_id"
      echo ${gatk_local_realign_qsub_cmd} > $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_local_realign_job_id.qsub
      cat sahgp.gatk_local_realign_on_picard_marked_duplicates.bwamem.picard_ready.single.sh > $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_local_realign_job_id.sh
      cat $config > $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_local_realign_job_id.config

      qalter -o $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_local_realign_job_id.o $gatk_local_realign_job_id
      qalter -e $logs_dir/sahgp.gatk_realign.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_local_realign_job_id.e $gatk_local_realign_job_id
    fi

    pstracker_log_path=$logs_dir"/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready."$sample_id"."$sample_count  
    gatk_bqsr_qsub_cmd="qsub -W depend=afterok:$gatk_local_realign_job_id -N sahgp.gbr.$sample_count -o $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.o -e $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.e -v config=$config,bam=$picard_mate_fixed_bam,gatk_bqsr_table=$gatk_bqsr_table,gatk_bqsr_bam=$gatk_bqsr_bam,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_bqsr_threads:mem=${gatk_bqsr_mem}B -l walltime=$gatk_bqsr_walltime -M gerrit.botha@uct.ac.za -m abe sahgp.gatk_bqsr_on_gatk_local_realign.picard_marked_duplicates.bwamem.picard_ready.single.sh"
  
    if [ $DEBUG -eq 1 ]
    then
      echo $gatk_bqsr_qsub_cmd
    else
      gatk_bqsr_job_id=`${gatk_bqsr_qsub_cmd}`
      echo "SAHGP: $sample_id, GATK BQSR: $gatk_bqsr_job_id"
   
      echo ${gatk_bqsr_qsub_cmd} > $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.qsub
      cat sahgp.gatk_bqsr_on_gatk_local_realign.picard_marked_duplicates.bwamem.picard_ready.single.sh > $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.sh
      cat $config > $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.config
      qalter -o $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.o $gatk_bqsr_job_id
      qalter -e $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.e $gatk_bqsr_job_id
    fi 
  # Check if GATK's BQSR bam index has been created 
  elif [ ! -f $gatk_bqsr_bai ] 
  then
    pstracker_log_path=$logs_dir"/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready."$sample_id"."$sample_count  
    gatk_bqsr_qsub_cmd="qsub -N sahgp.gbr.$sample_count -o $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.o -e $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.e -v config=$config,bam=$picard_mate_fixed_bam,gatk_bqsr_table=$gatk_bqsr_table,gatk_bqsr_bam=$gatk_bqsr_bam,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_bqsr_threads:mem=${gatk_bqsr_mem}B -l walltime=$gatk_bqsr_walltime -M gerrit.botha@uct.ac.za -m abe sahgp.gatk_bqsr_on_gatk_local_realign.picard_marked_duplicates.bwamem.picard_ready.single.sh"
  
    if [ $DEBUG -eq 1 ]
    then
      echo $gatk_bqsr_qsub_cmd
    else
      gatk_bqsr_job_id=`${gatk_bqsr_qsub_cmd}`
      echo "SAHGP: $sample_id, GATK BQSR: $gatk_bqsr_job_id"
   
      echo ${gatk_bqsr_qsub_cmd} > $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.qsub
      cat sahgp.gatk_bqsr_on_gatk_local_realign.picard_marked_duplicates.bwamem.picard_ready.single.sh > $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.sh
      cat $config > $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.config
      qalter -o $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.o $gatk_bqsr_job_id
      qalter -e $logs_dir/sahgp.gatk_bqsr.picard_sort_index_realign_recal_on_bwamem.picard_ready.$sample_id.$sample_count.$gatk_bqsr_job_id.e $gatk_bqsr_job_id
    fi
  else
    echo "All BAMs for sample "$sample_id" have been created" 
  fi

  (( sample_count+=1 ))

#done
done < $bam_list

