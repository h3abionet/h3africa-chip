#!/bin/bash
queue=R807693
config=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/sahgp/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config
sahgp_dir=/lustre/SCRATCH5/groups/h3a/samples/sahgp
logs_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/sahgp/logs

sahgp_bam2fastq_job_ids='';
bam_count=1
for bam in `ls $sahgp_dir/*/*.bam`; 
do
  filename=$(basename $bam)
  #sahgp_bam2fastq_job_id=`qsub -N sahgp.b2fq.$bam_count -o $logs_dir/sahgp.bam2fastq.$filename.$bam_count.o -e $logs_dir/sahgp.bam2fastq.$filename.$bam_count.e -v config=$config,bam=$bam -q $queue -l select=1:ncpus=$bam2fastq_threads:mem=${bam2fastq_mem}B -l walltime=$bam2fastq_walltime  sahgp.bam2fastq.single.sh`
  sahgp_bam2fastq_job_id=`qsub -N sahgp.b2fq.$bam_count -o $logs_dir/sahgp.bam2fastq.$filename.$bam_count.o -e $logs_dir/sahgp.bam2fastq.$filename.$bam_count.e -v config=$config,bam=$bam -q $queue -l select=1:ncpus=8:nodetype=nehalem:mem=${bam2fastq_mem}B -l walltime=$bam2fastq_walltime  sahgp.bam2fastq.single.sh`
  sahgp_bam2fastq_job_ids=$sahgp_bam2fastq_job_id":"$sahgp_bam2fastq_job_ids
  echo "SAHGP Bam2Fastq: $sahgp_bam2fastq_job_id"
  qalter -o $logs_dir/sahgp.bam2fastq.$filename.$bam_count.$sahgp_bam2fastq_job_id.o $sahgp_bam2fastq_job_id
  qalter -e $logs_dir/sahgp.bam2fastq.$filename.$bam_count.$sahgp_bam2fastq_job_id.e $sahgp_bam2fastq_job_id
  (( bam_count+=1 ))
done

sahgp_bam2fastq_job_ids_length=${#sahgp_bam2fastq_job_ids}
(( sahgp_bam2fastq_job_ids_length-=1 ))
sahgp_bam2fastq_job_ids=${sahgp_bam2fastq_job_ids: 0: $sahgp_bam2fastq_job_ids_length}




