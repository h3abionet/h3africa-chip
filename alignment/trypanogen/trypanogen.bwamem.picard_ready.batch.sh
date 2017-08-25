#!/bin/bash
DEBUG=0

queue=H3A
config=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/trypanogen/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

picard_ready_dir=$picard_ready_dir
logs_dir=$logs_dir"/picard_ready."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

sample_dir_list=trypanogen.bwamem.picard_ready.batch.sample_dir_list

sample_count=1

while read sample_dir; 
do
  sample_id=$(basename $sample_dir)
  bam_readgroup_info="\"@RG\tID:$sample_id.0\tLB:LIBA\tSM:$sample_id\tPL:Illumina\""
  f1=$sample_dir/$sample_id"_R1.fastq.gz"
  f2=$sample_dir/$sample_id"_R2.fastq.gz"
  bam=$picard_ready_dir/$sample_id."bwa.sorted.bam"
  bai=$picard_ready_dir/$sample_id."bwa.sorted.bai"
  

  # First check if marked duplicate bai has been generated 
  if [ ! -f $bai ]; then

    pstracker_log_path=$logs_dir"/trypanogen.bwamem.picard_ready."$sample_id"."$sample_count

    bwamem_cmd="qsub -N tg.bmpr.$sample_count -o $logs_dir/trypanogen.bwamem.picard_ready.$sample_id.$sample_count.o -e $logs_dir/trypanogen.bwamem.picard_ready.$sample_id.$sample_count.e -v config=$config,sample_id=$sample_id,bam_readgroup_info=$bam_readgroup_info,f1=$f1,f2=$f2,bam=$bam,bai=$bai,pstracker_log_path=$pstracker_log_path  -q $queue -l select=1:ncpus=$bwamem_threads:mem=${bwamem_mem}B -l walltime=$bwamem_walltime -M $pbs_status_mailto -m abe trypanogen.bwamem.picard_ready.single.sh"
  
    if [ $DEBUG -eq 1 ]; then
      echo $sample_id
      echo $bwamem_cmd 
    else  
      bwamem_job_id=`${bwamem_cmd}`
      #bwamem_job_id=`eval $bwamem_cmd`
      echo "TrypanoGEN bwamem: $bwamem_job_id"
      echo ${bwamem_cmd} > $logs_dir/trypanogen.bwamem.picard_ready.$sample_id.$sample_count.$bwamem_job_id.qsub
      cat trypanogen.bwamem.picard_ready.single.sh > $logs_dir/trypanogen.bwamem.picard_ready.$sample_id.$sample_count.$bwamem_job_id.sh
      cat $config > $logs_dir/trypanogen.bwamem.picard_ready.$sample_id.$sample_count.$bwamem_job_id.config
      qalter -o $logs_dir/trypanogen.bwamem.picard_ready.$sample_id.$sample_count.$bwamem_job_id.o $bwamem_job_id
      qalter -e $logs_dir/trypanogen.bwamem.picard_ready.$sample_id.$sample_count.$bwamem_job_id.e $bwamem_job_id
    fi
  else
    echo "$bai for $sample_id exists. Therefor $sample_id has been alignened and are ready for downstream processing." 
  fi
 


  (( sample_count+=1 ))

done < $sample_dir_list
