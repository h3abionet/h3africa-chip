#!/bin/bash
DEBUG=0

queue=dev
config=/home/gerrit/projects/chipdesign/variant_calling/baylor/dm/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

tmp_dir=$tmp_dir

genotype_gvcfs_dir=$genotype_gvcfs_dir
genotype_gvcfs_with_basic_annotation_dir=$genotype_gvcfs_with_basic_annotation_dir

cohort=$cohort
logs_dir=$logs_dir"/prepare_basic_annotation.genotype_gvcfs."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

for i in $genotype_gvcfs_dir/$cohort.*.vcf.gz
do
  echo $i
  vcf=$(basename "$i")
  prefix=${vcf%.vcf.gz}
  vcf_with_basic_annotation=$genotype_gvcfs_with_basic_annotation_dir"/"$prefix".basic_annotation".vcf.gz
  echo $vcf_with_basic_annotation
  vcf_with_basic_annotation_tbi=$vcf_with_basic_annotation".tbi"
 
  vcf=$i
 
  site_name="${vcf%.vcf.gz}"
  site_name="${site_name##*.}"

  if [ ! -f $vcf_with_basic_annotation_tbi ]; then
    cmd="qsub -N $cohort.pbag.$site_name -o $logs_dir/$cohort.prepare_basic_annotation.genotype_gvcfs.$site_name.o -e $logs_dir/$cohort.prepare_basic_annotation.genotype_gvcfs.$site_name.e -v config=$config,vcf=$vcf,vcf_with_basic_annotation=$vcf_with_basic_annotation -q $queue -l nodes=1:ppn=1 -l walltime=72:00:00 -M $pbs_status_mailto -m abe $cohort.prepare_basic_annotation.prepare_for_cross_impute.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $cmd
    else 
      job_id=`eval $cmd`
      echo "$cohort: site: $site_name, prepare_basic_annotation: $job_id"
      echo ${cmd} > $logs_dir/$cohort.pba.$site_name.$job_id.qsub
    fi
  else
    echo "$vcf_with_basic_annotation for cohort:$cohort, site:$site_name has already been created" 
  fi

done
