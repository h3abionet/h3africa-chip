#!/bin/bash
DEBUG=0

queue=dev
config=/home/gerrit/projects/chipdesign/variant_calling/h3a/dm/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

tmp_dir=$tmp_dir

# The combine_gvcfs_dir directory must contain a per site per batched vcfs
# For example
# /shuffle/projects/chipdesign/variant_calling/baylor/combine_gvcfs
# h3a.1.batch0.vcf.gz
# h3a.1.batch1.vcf.gz
# h3a.2.batch0.vcf.gz
# h3a.2.batch1.vcf.gz
# ...
# h3a.1.batch0.vcf.gz
# h3a.22.batch1.vcf.gz
combine_gvcfs_dir=$combine_gvcfs_dir
genotype_gvcfs_dir=$genotype_gvcfs_dir
cohort=$cohort
logs_dir=$logs_dir"/genotype_gvcfs."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

gatk_genotype_gvcfs_threads=$(( $gatk_genotype_gvcfs_data_threads*$gatk_genotype_gvcfs_cpu_threads_per_data_thread ))


# GenotypeGVCFs the autosomes
#for i in {1..22}; do
for i in {1..17}; do

  # Sanger high qual site path
#  site="-L /shuffle/projects/chipdesign/sanger/AGR_stuff/$i.vcf.gz"
  # H3A high qual site path
#  site=$site" -L /shuffle/projects/chipdesign/variant_calling/phasing_ready_redo/$i.post-vqsr.sites.vcf.gz"
  
   # Created own union of sites contatianig chrom:positions e.g. 1:10120
 # site="-L /shuffle/projects/chipdesign/variant_calling/post_process/h3a_vs_sanger/$i.list"
  site="-L /shuffle/projects/chipdesign/variant_calling/post_process/h3a_vs_sanger/trunc_run/$i.trunc.list"
  
  site_name=$i
  ls -1 $combine_gvcfs_dir/$cohort.$site_name."batch"*".g.vcf.gz" > $tmp_dir/$cohort.$site_name.g.vcf.gz.list
  gvcf_list=$tmp_dir/$cohort.$site_name.g.vcf.gz.list
  vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"
  tbi=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz.tbi"
  
  if [ ! -f $tbi ]; then
    genotype_gvcfs_cmd="qsub -N h3a.gtg.$site_name -o $logs_dir/h3a.genotype_gvcfs.$site_name.o -e $logs_dir/h3a.genotype_gvcfs.$site_name.e -v config=$config,gvcf_list=$gvcf_list,site=\"$site\",vcf=$vcf -q $queue -l nodes=1:ppn=$gatk_genotype_gvcfs_threads -l walltime=$gatk_genotype_gvcfs_walltime -M $pbs_status_mailto -m abe h3a.genotype_gvcfs.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $genotype_gvcfs_cmd
    else 
      genotype_gvcfs_job_id=`eval $genotype_gvcfs_cmd`
      echo "Baylor: site: $site_name, genotype_gvcfs_job_id: $genotype_gvcfs_job_id"
      echo ${genotype_gvcfs_cmd} > $logs_dir/h3a.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.qsub
      cat h3a.genotype_gvcfs.single.sh > $logs_dir/h3a.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.sh
      cat $config > $logs_dir/h3a.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.config
    
      qalter -o $logs_dir/h3a.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.o $genotype_gvcfs_job_id
      qalter -e $logs_dir/h3a.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.e $genotype_gvcfs_job_id
    fi
  else
    echo "$vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
done
