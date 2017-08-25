#!/bin/bash
DEBUG=0

queue=dev
config=/home/gerrit/projects/chipdesign/variant_calling/h3a/dm/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

tmp_dir=$tmp_dir

genotype_gvcfs_dir=$genotype_gvcfs_dir
clean_vcfs_dir=$clean_vcfs_dir
cohort=$cohort

logs_dir=$logs_dir"/clean_vcfs."`date +"%y%m%d%H%M%S"`

mkdir $logs_dir 

clean_vcfs_threads=$(( $gatk_prepare_cross_impute_data_threads*$gatk_prepare_cross_impute_cpu_threads_per_data_thread ))

#for i in 20; do 
#for i in {18,19,21,22}; do 
#for i in 17; do 
#for i in {3,4,6,7,8,9,10,11,12,13,14,15,16}; do 
for i in {1,2,5}; do 
  site_name=$i
  site="-L "$i

  #genotyped_vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"
  genotyped_vcf=$genotype_gvcfs_dir/$i/$cohort.$site_name".vcf.gz"

  clean_vcf=$clean_vcfs_dir/$cohort.$site_name".cleaned.vcf.gz"
  clean_tbi=$cross_impute_ready_dir/$cohort.$site_name".cleaned.tbi"

  if [ ! -f $clean_tbi ]; then
    clean_cmd="qsub -N h3a.cleanvcf.$site_name -o $logs_dir/h3a.clean.$site_name.o -e $logs_dir/h3a.clean.$site_name.e -v config=$config,genotyped_vcf=$genotyped_vcf,clean_vcf=$clean_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$clean_vcfs_threads -l walltime=$prepare_cross_impute_walltime -M $pbs_status_mailto -m abe h3a.clean_vcf.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $clean_cmd
    else 
      clean_job_id=`eval $clean_cmd`
      echo "H3A: site: $site_name, clean_job_id: $clean_job_id"
      echo ${clean_cmd} > $logs_dir/h3a.clean_vcf.$site_name.$clean_job_id.qsub
      cat h3a.clean_vcf.single.sh > $logs_dir/h3a.clean_vcf.$site_name.$clean_job_id.sh
      cat $config > $logs_dir/h3a.clean_vcf.$site_name.$clean_job_id.config
    
      qalter -o $logs_dir/h3a.clean_vcf.$site_name.$clean_job_id.o $clean_job_id
      qalter -e $logs_dir/h3a.clean_vcf.$site_name.$clean_job_id.e $clean_job_id
    fi
  else
    echo "$clean_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
done
