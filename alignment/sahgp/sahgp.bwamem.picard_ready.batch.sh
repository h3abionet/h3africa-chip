#!/bin/bash
queue=R807693
config=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/sahgp/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config
sahgp_dir=/lustre/SCRATCH5/groups/h3a/samples/sahgp
logs_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/sahgp/logs

logs_dir=$logs_dir"/picard_ready."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

sahgp_bwa_mem_job_ids='';
sample_count=1
#for sample_dir in `ls -d $sahgp_dir/LP6005857-DNA*/`; 
for sample_dir in `ls -d $sahgp_dir/LP6005857-DNA*H01/ $sahgp_dir/LP6005857-DNA*H02/ $sahgp_dir/LP6005857-DNA*H03/`;
do
  sample_id=$(basename $sample_dir)
  bam_readgroup_info="@RG\tID:$sample_id.0\tLB:LIBA\tSM:$sample_id\tPL:Illumina"
  f1=$sample_dir/$sample_id."f1.fastq.gz"
  f2=$sample_dir/$sample_id."f2.fastq.gz"
  sahgp_bwamem_qsub_cmd="qsub -N sahgp.bmpr.$sample_count -o $logs_dir/sahgp.bwamem.picard_ready.$sample_id.$sample_count.o -e $logs_dir/sahgp.bwamem.picard_ready.$sample_id.$sample_count.e -v config=$config,sample_id=$sample_id,bam_readgroup_info=$bam_readgroup_info,f1=$f1,f2=$f2 -q $queue -l select=1:ncpus=$bwamem_threads:mem=${bwamem_mem}B -l walltime=$bwamem_walltime -M gerrit.botha@uct.ac.za -m abe sahgp.bwamem.picard_ready.single.sh"
  sahgp_bwamem_job_id=`${sahgp_bwamem_qsub_cmd}`

  echo ${sahgp_bwamem_qsub_cmd} > $logs_dir/sahgp.bwamem.picard_ready.$sample_id.$sample_count.$sahgp_bwamem_job_id.qsub
  cat sahgp.bwamem.single.sh > $logs_dir/sahgp.bwamem.picard_ready.$sample_id.$sample_count.$sahgp_bwamem_job_id.sh
  cat $config > $logs_dir/sahgp.bwamem.picard_ready.$sample_id.$sample_count.$sahgp_bwamem_job_id.config

  sahgp_bwamem_job_ids=$sahgp_bwamem_job_id":"$sahgp_bwamem_job_ids
  echo "SAHGP bwamem: $sahgp_bwamem_job_id"
  qalter -o $logs_dir/sahgp.bwamem.picard_ready.$sample_id.$sample_count.$sahgp_bwamem_job_id.o $sahgp_bwamem_job_id
  qalter -e $logs_dir/sahgp.bwamem.picard_ready.$sample_id.$sample_count.$sahgp_bwamem_job_id.e $sahgp_bwamem_job_id
  (( sample_count+=1 ))
done

sahgp_bwamem_job_ids_length=${#sahgp_bwamem_job_ids}
(( sahgp_bwamem_job_ids_length-=1 ))
sahgp_bwamem_job_ids=${sahgp_bwamem_job_ids: 0: $sahgp_bwamem_job_ids_length}
