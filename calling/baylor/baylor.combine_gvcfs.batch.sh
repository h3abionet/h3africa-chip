#!/bin/bash
DEBUG=0

queue=batch
config=/home/gerrit/projects/chipdesign/variant_calling/baylor/dm/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

tmp_dir=$tmp_dir

# The genotype_gvcfs_ready_dir directory must contain a sample/(combined gvcf) folder and the per site vcfs in there
# For example
# /shuffle/projects/chipdesign/variant_calling/baylor/dm/IBQ0T
# 1.realrecal.IBQ0T.calmd.bam.1.raw.g.vcf.gz
# .
# ..
# ...
# 22.realrecal.IBQ0T.calmd.bam.22.raw.g.vcf.gz
genotype_gvcfs_ready_dir=$genotype_gvcfs_ready_dir
combine_gvcfs_dir=$combine_gvcfs_dir
cohort=$cohort
logs_dir=$logs_dir"/combine_gvcfs."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

gatk_combine_gvcfs_threads=$(( $gatk_combine_gvcfs_data_threads*$gatk_combine_gvcfs_cpu_threads_per_data_thread ))

# CombineGVCFs the autosomes
for i in {1..2}; do 
  site="-L "$i
  site_name=$i

  rm -rf $cohort.$site_name.complete.g.vcf.gz.list

  ls -1 $genotype_gvcfs_ready_dir/*/*.$site_name.raw.g.vcf.gz > $tmp_dir/$cohort.$site_name.complete.g.vcf.gz.list
  complete_gvcf_list=$tmp_dir/$cohort.$site_name.complete.g.vcf.gz.list

  # Just remove temporary batch files if there are any
  rm -rf $complete_gvcf_list.batch.*
 
  split -d -l 200 $complete_gvcf_list $complete_gvcf_list.batch.

  count=0

  for i in `ls $complete_gvcf_list.batch.*`;
  do
   mv $i $i.list
   batch_gvcf_list=$i.list

   echo $batch_gvcf_list

   vcf=$combine_gvcfs_dir/$cohort.$site_name".batch$count.g.vcf.gz"
   tbi=$combine_gvcfs_dir/$cohort.$site_name".batch$count.g.vcf.gz.tbi"

   if [ ! -f $tbi ]; then
    combine_gvcfs_cmd="qsub -N baylor.cmg.$site_name.batch$count -o $logs_dir/baylor.combine_gvcfs.$site_name.batch$count.o -e $logs_dir/baylor.combine_gvcfs.$site_name.batch$count.e -v config=$config,gvcf_list=$batch_gvcf_list,site=\"$site\",vcf=$vcf -q $queue -l nodes=1:ppn=$gatk_combine_gvcfs_threads -l walltime=$gatk_combine_gvcfs_walltime -M $pbs_status_mailto -m abe baylor.combine_gvcfs.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
     echo $combine_gvcfs_cmd
    else 
      combine_gvcfs_job_id=`eval $combine_gvcfs_cmd`
      echo "Baylor: site: $site_name, batch: $count combine_gvcfs_job_id: $genotype_gvcfs_job_id"
      echo ${combine_gvcfs_cmd} > $logs_dir/baylor.combine_gvcfs.$site_name.batch$count.$combine_gvcfs_job_id.qsub
      cat baylor.combine_gvcfs.single.sh > $logs_dir/baylor.combine_gvcfs.$site_name.batch$count.$combine_gvcfs_job_id.sh
      cat $config > $logs_dir/baylor.combine_gvcfs.$site_name.batch$count.$combine_gvcfs_job_id.config
    
      qalter -o $logs_dir/baylor.combine_gvcfs.$site_name.batch$count.$combine_gvcfs_job_id.o $combine_gvcfs_job_id
      qalter -e $logs_dir/baylor.combine_gvcfs.$site_name.batch$count.$combine_gvcfs_job_id.e $combine_gvcfs_job_id
    fi
  else
    echo "$vcf for cohort:$cohort, site:$site_name batch:$count has already been created" 
  fi


   (( count+=1 ))

  done;  


done

