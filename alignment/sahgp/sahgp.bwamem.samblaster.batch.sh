#!/bin/bash
queue=R807693
config=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/sahgp/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config
sahgp_dir=/lustre/SCRATCH5/groups/h3a/samples/sahgp
marked_duplicates_dir=$samblaster_marked_duplicates_dir
logs_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/sahgp/logs
logs_dir=$logs_dir"/bwamem.samblaster."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

sahgp_bwa_mem_job_ids='';
sample_count=1
for sample_dir in `ls -d $sahgp_dir/LP6005857-DNA*/`; 
#for sample_dir in `ls -d $sahgp_dir/LP6005857-DNA*H01/ $sahgp_dir/LP6005857-DNA*H02/ $sahgp_dir/LP6005857-DNA*H03/`;
do
  sample_id=$(basename $sample_dir)
  marked_duplicates_bam=$marked_duplicates_dir"/"$sample_id".marked_duplicates.bam"
  bam_readgroup_info="@RG\tID:$sample_id.0\tLB:LIBA\tSM:$sample_id\tPL:Illumina"
  log_id="sahgp.bwamem.samblaster."$sample_id"."$sample_count
  f1=$sample_dir/$sample_id."f1.fastq.gz"
  f2=$sample_dir/$sample_id."f2.fastq.gz"
  sahgp_bwamem_qsub_cmd="qsub -N sahgp.bmsb.$sample_count -o $logs_dir/sahgp.bwamem.samblaster.$sample_id.$sample_count.o -e $logs_dir/sahgp.bwamem.samblaster.$sample_id.$sample_count.e -v config=$config,bam_readgroup_info=$bam_readgroup_info,f1=$f1,f2=$f2,md_bam=$marked_duplicates_bam,logs_dir=$logs_dir,log_id=$log_id -q $queue -l select=1:ncpus=$bwamem_threads:mem=${bwamem_mem}B -l walltime=$bwamem_walltime -M gerrit.botha@uct.ac.za -m abe sahgp.bwamem.samblaster.single.sh"
  sahgp_bwamem_job_id=`${sahgp_bwamem_qsub_cmd}`

  echo ${sahgp_bwamem_qsub_cmd} > $logs_dir/sahgp.bwamem.samblaster.$sample_id.$sample_count.$sahgp_bwamem_job_id.qsub
  cat sahgp.bwamem.samblaster.single.sh > $logs_dir/sahgp.bwamem.samblaster.$sample_id.$sample_count.$sahgp_bwamem_job_id.sh
  cat $config > $logs_dir/sahgp.bwamem.samblaster.$sample_id.$sample_count.$sahgp_bwamem_job_id.config

  sahgp_bwamem_job_ids=$sahgp_bwamem_job_id":"$sahgp_bwamem_job_ids
  echo "SAHGP bwamem.samblaster: $sahgp_bwamem_job_id"
  qalter -o $logs_dir/sahgp.bwamem.samblaster.$sample_id.$sample_count.$sahgp_bwamem_job_id.o $sahgp_bwamem_job_id
  qalter -e $logs_dir/sahgp.bwamem.samblaster.$sample_id.$sample_count.$sahgp_bwamem_job_id.e $sahgp_bwamem_job_id
  (( sample_count+=1 ))
done

