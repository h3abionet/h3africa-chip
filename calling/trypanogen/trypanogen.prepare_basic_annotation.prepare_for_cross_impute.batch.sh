#!/bin/bash
DEBUG=0

queue=dev
config=/home/gerrit/projects/chipdesign/variant_calling/trypanogen/dm/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

tmp_dir=$tmp_dir

cross_impute_ready_dir=$cross_impute_ready_dir

cohort=$cohort
logs_dir=$logs_dir"/prepare_basic_annotation.prepare_for_cross_impute."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

for i in $cross_impute_ready_dir/*.vqsr.cross_impute_ready.vcf.gz
do
  echo $i
  vcf=$(basename "$i")
  vcf_with_basic_annotation=$cross_impute_ready_dir"/""${vcf/cross_impute_ready/cross_impute_ready.basic_annotation}"
  echo $vcf_with_basic_annotation
  vcf_with_basic_annotation_tbi=$vcf_with_basic_annotation".tbi"
 
  vcf=$i
 
  site_name="${vcf%.vqsr*}"
  site_name="${site_name##*.}"

  if [ ! -f $vcf_with_basic_annotation_tbi ]; then
    cmd="qsub -N $cohort.pba.$site_name -o $logs_dir/$cohort.prepare_basic_annotation.prepare_for_cross_impute.$site_name.o -e $logs_dir/$cohort.prepare_basic_annotation.prepare_for_cross_impute.$site_name.e -v config=$config,vcf=$vcf,vcf_with_basic_annotation=$vcf_with_basic_annotation -q $queue -l nodes=1:ppn=1 -l walltime=72:00:00 -M $pbs_status_mailto -m abe $cohort.prepare_basic_annotation.prepare_for_cross_impute.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $cmd
    else 
      job_id=`eval $cmd`
      echo "$cohort: site: $site_name, prepare_basic_annotation: $job_id"
      echo ${cmd} > $logs_dir/$cohort.pba.$site_name.$job_id.qsub
    fi
  else
    echo "$vcf_with_basic_annotatio for cohort:$cohort, site:$site_name has already been created" 
  fi

done
