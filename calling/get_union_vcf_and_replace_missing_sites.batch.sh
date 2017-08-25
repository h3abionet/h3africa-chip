#!/bin/bash
DEBUG=0

queue=dev
config=/home/gerrit/projects/chipdesign/variant_calling/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

tmp_dir=$tmp_dir

#genotype_gvcfs_dir_baylor=$genotype_gvcfs_dir_baylor
#genotype_gvcfs_dir_sahgp=$genotype_gvcfs_dir_sahgp
#genotype_gvcfs_dir_trypanogen=$genotype_gvcfs_dir_trypanogen

genotype_gvcfs_with_basic_annotation_dir_baylor=$genotype_gvcfs_with_basic_annotation_dir_baylor
genotype_gvcfs_with_basic_annotation_dir_sahgp=$genotype_gvcfs_with_basic_annotation_dir_sahgp
genotype_gvcfs_with_basic_annotation_dir_trypanogen=$genotype_gvcfs_with_basic_annotation_dir_trypanogen

cross_impute_ready_dir_baylor=$cross_impute_ready_dir_baylor
cross_impute_ready_dir_sahgp=$cross_impute_ready_dir_sahgp
cross_impute_ready_dir_trypanogen=$cross_impute_ready_dir_trypanogen

phasing_ready_dir=$phasing_ready_dir

logs_dir=$logs_dir"/get_union_vcf_and_replace_missing_sites."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

# Not running threaded at the moment but might later, so keeping this in.
#combine_variants_threads=$(( $gatk_combine_variants_data_threads*$gatk_combine_variants_cpu_threads_per_data_thread ))
# bcftools run single treaded
combine_variants_threads=1

# In submissions scripts we are just using gatk_combine_variants walltime for now

for i in {1..22}; do 
#for i in {1..19}; do 
#for i in 21; do 
#for i ; do 
#for i in 20 22 ; do 
  site_name=$i
  site="-L "$i
  
  cross_impute_ready_vcf_baylor=$cross_impute_ready_dir_baylor/baylor.$site_name."vqsr.cross_impute_ready.basic_annotation.vcf.gz"
  cross_impute_ready_vcf_sahgp=$cross_impute_ready_dir_sahgp/sahgp.$site_name."vqsr.cross_impute_ready.basic_annotation.vcf.gz"
  cross_impute_ready_vcf_trypanogen=$cross_impute_ready_dir_trypanogen/trypanogen.$site_name."vqsr.cross_impute_ready.basic_annotation.vcf.gz"
  
  genotype_gvcfs_vcf_baylor=$genotype_gvcfs_with_basic_annotation_dir_baylor/baylor.$site_name".basic_annotation.vcf.gz"
  genotype_gvcfs_vcf_sahgp=$genotype_gvcfs_with_basic_annotation_dir_sahgp/sahgp.$site_name".basic_annotation.vcf.gz"
  genotype_gvcfs_vcf_trypanogen=$genotype_gvcfs_with_basic_annotation_dir_trypanogen/trypanogen.$site_name".basic_annotation.vcf.gz"
   
  post_vqsr_union_vcf=$phasing_ready_dir/$site_name.post-vqsr.sites.vcf.gz
  post_vqsr_union_tbi=$phasing_ready_dir/$site_name.post-vqsr.sites.vcf.gz.tbi
  
  pre_vqsr_union_vcf=$phasing_ready_dir/$site_name.pre-vqsr.vcf.gz
  pre_vqsr_union_tbi=$phasing_ready_dir/$site_name.pre-vqsr.vcf.gz.tbi
  
  # Setting a vcf here. In the job script it will be created as .gz.
  pre_vqsr_union_replace_missing_vcf=$phasing_ready_dir/$site_name.pre-vqsr.replaced_missing_with_refref.vcf.gz
  pre_vqsr_union_replace_missing_tbi=$phasing_ready_dir/$site_name.pre-vqsr.replaced_missing_with_refref.vcf.gz.tbi

  if [ ! -f $post_vqsr_union_tbi ]; then
    get_union_post_vqsr_cmd="qsub -N gupov.$site_name -o $logs_dir/get_union_post_vqsr.$site_name.o -e $logs_dir/get_union_post_vqsr.$site_name.e -v config=$config,cross_impute_ready_vcf_baylor=$cross_impute_ready_vcf_baylor,cross_impute_ready_vcf_sahgp=$cross_impute_ready_vcf_sahgp,cross_impute_ready_vcf_trypanogen=$cross_impute_ready_vcf_trypanogen,post_vqsr_union_vcf=$post_vqsr_union_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$combine_variants_threads -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_post_vqsr.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $get_union_post_vqsr_cmd
    else 
      get_union_post_vqsr_job_id=`eval $get_union_post_vqsr_cmd`
      echo "get_union_post_vqsr: site: $site_name, get_union_post_vqsr_job_id: $get_union_post_vqsr_job_id"
      echo ${get_union_post_vqsr_cmd} > $logs_dir/get_union_post_vqsr.$site_name.$get_union_post_vqsr_job_id.qsub
      cat get_union_post_vqsr.single.sh > $logs_dir/get_union_post_vqsr.$site_name.$get_union_post_vqsr_job_id.sh
      cat $config > $logs_dir/get_union_post_vqsr.$site_name.$get_union_post_vqsr_job_id.config
    
      qalter -o $logs_dir/get_union_post_vqsr.$site_name.$get_union_post_vqsr_job_id.o $get_union_post_vqsr_job_id
      qalter -e $logs_dir/get_union_post_vqsr.$site_name.$get_union_post_vqsr_job_id.e $get_union_post_vqsr_job_id
    fi

     get_union_pre_vqsr_cmd="qsub -W depend=afterok:$get_union_post_vqsr_job_id -N guprev.$site_name -o $logs_dir/get_union_pre_vqsr.$site_name.o -e $logs_dir/get_union_pre_vqsr.$site_name.e -v config=$config,genotype_gvcfs_vcf_baylor=$genotype_gvcfs_vcf_baylor,genotype_gvcfs_vcf_sahgp=$genotype_gvcfs_vcf_sahgp,genotype_gvcfs_vcf_trypanogen=$genotype_gvcfs_vcf_trypanogen,post_vqsr_union_vcf=$post_vqsr_union_vcf,pre_vqsr_union_vcf=$pre_vqsr_union_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$combine_variants_threads -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_pre_vqsr.single.sh"
  
    if [ $DEBUG -eq 1 ]; then
      echo $get_union_pre_vqsr_cmd
    else
      get_union_pre_vqsr_job_id=`eval $get_union_pre_vqsr_cmd`
      echo "get_union_pre_vqsr: site: $site_name, get_union_pre_vqsr_job_id: $get_union_pre_vqsr_job_id"
      echo ${get_union_pre_vqsr_cmd} > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.qsub
      cat get_union_pre_vqsr.single.sh > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.sh
      cat $config > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.config
  
      qalter -o $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.o $get_union_pre_vqsr_job_id
      qalter -e $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.e $get_union_pre_vqsr_job_id
    fi
  
    get_union_pre_vqsr_replace_missing_cmd="qsub -W depend=afterok:$get_union_pre_vqsr_job_id -N guprevrm.$site_name -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.o -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.e -v config=$config,pre_vqsr_union_vcf=$pre_vqsr_union_vcf,pre_vqsr_union_replace_missing_vcf=$pre_vqsr_union_replace_missing_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=1 -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_pre_vqsr_replace_missing.single.sh"
  
    if [ $DEBUG -eq 1 ]; then
      echo $get_union_pre_vqsr_replace_missing_cmd
    else
      get_union_pre_vqsr_replace_missing_job_id=`eval $get_union_pre_vqsr_replace_missing_cmd`
      echo "get_union_pre_vqsr_replace_missing site: $site_name, get_union_pre_vqsr_replace_missing_job_id: $get_union_pre_vqsr_replace_missing_job_id"
      echo ${get_union_pre_vqsr_replace_missing_cmd} > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.qsub
      cat get_union_pre_vqsr_replace_missing.single.sh > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.sh
      cat $config > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.config
  
      qalter -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.o $get_union_pre_vqsr_replace_missing_job_id
      qalter -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.e $get_union_pre_vqsr_replace_missing_job_id
    fi
  # if post_vqsr_union has been created just go on with pre_vqsr_union
  elif [ ! -f $pre_vqsr_union_tbi ]; then
    get_union_pre_vqsr_cmd="qsub -N guprev.$site_name -o $logs_dir/get_union_pre_vqsr.$site_name.o -e $logs_dir/get_union_pre_vqsr.$site_name.e -v config=$config,genotype_gvcfs_vcf_baylor=$genotype_gvcfs_vcf_baylor,genotype_gvcfs_vcf_sahgp=$genotype_gvcfs_vcf_sahgp,genotype_gvcfs_vcf_trypanogen=$genotype_gvcfs_vcf_trypanogen,post_vqsr_union_vcf=$post_vqsr_union_vcf,pre_vqsr_union_vcf=$pre_vqsr_union_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$combine_variants_threads -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_pre_vqsr.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $get_union_pre_vqsr_cmd
    else
      get_union_pre_vqsr_job_id=`eval $get_union_pre_vqsr_cmd`
      echo "get_union_pre_vqsr: site: $site_name, get_union_pre_vqsr_job_id: $get_union_pre_vqsr_job_id"
      echo ${get_union_pre_vqsr_cmd} > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.qsub
      cat get_union_pre_vqsr.single.sh > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.sh
      cat $config > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.config

      qalter -o $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.o $get_union_pre_vqsr_job_id
      qalter -e $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.e $get_union_pre_vqsr_job_id
    fi
    
    get_union_pre_vqsr_replace_missing_cmd="qsub -W depend=afterok:$get_union_pre_vqsr_job_id -N guprevrm.$site_name -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.o -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.e -v config=$config,pre_vqsr_union_vcf=$pre_vqsr_union_vcf,pre_vqsr_union_replace_missing_vcf=$pre_vqsr_union_replace_missing_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=1 -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_pre_vqsr_replace_missing.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $get_union_pre_vqsr_replace_missing_cmd
    else
      get_union_pre_vqsr_replace_missing_job_id=`eval $get_union_pre_vqsr_replace_missing_cmd`
      echo "get_union_pre_vqsr_replace_missing site: $site_name, get_union_pre_vqsr_replace_missing_job_id: $get_union_pre_vqsr_replace_missing_job_id"
      echo ${get_union_pre_vqsr_replace_missing_cmd} > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.qsub
      cat get_union_pre_vqsr_replace_missing.single.sh > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.sh
      cat $config > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.config

      qalter -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.o $get_union_pre_vqsr_replace_missing_job_id
      qalter -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.e $get_union_pre_vqsr_replace_missing_job_id
    fi
  elif [ ! -f $pre_vqsr_union_replace_missing_tbi ]; then 
  # if pre_vqsr_union has been created just go on with pre_vqsr_union_replace_missing_vcf
    get_union_pre_vqsr_replace_missing_cmd="qsub -n guprevrm.$site_name -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.o -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.e -v config=$config,pre_vqsr_union_vcf=$pre_vqsr_union_vcf,pre_vqsr_union_replace_missing_vcf=$pre_vqsr_union_replace_missing_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=1 -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_pre_vqsr_replace_missing.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $get_union_pre_vqsr_replace_missing_cmd
    else
      get_union_pre_vqsr_replace_missing_job_id=`eval $get_union_pre_vqsr_replace_missing_cmd`
      echo "get_union_pre_vqsr_replace_missing site: $site_name, get_union_pre_vqsr_replace_missing_job_id: $get_union_pre_vqsr_replace_missing_job_id"
      echo ${get_union_pre_vqsr_replace_missing_cmd} > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.qsub
      cat get_union_pre_vqsr_replace_missing.single.sh > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.sh
      cat $config > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.config

      qalter -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.o $get_union_pre_vqsr_replace_missing_job_id
      qalter -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.e $get_union_pre_vqsr_replace_missing_job_id
    fi
    #echo "$pre_vqsr_union_replace_missing_vcf, site:$site_name has already been created" 
    echo "All .tbis for site:$site_name have been created" 
  fi
done

## X
site="-L X"
site_name="X.male.female"

cross_impute_ready_vcf_baylor=$X_ready_dir_baylor/baylor.$site_name."vqsr.cross_impute_ready.basic_annotation.vcf.gz"
cross_impute_ready_vcf_sahgp=$X_ready_dir_sahgp/sahgp.$site_name."vqsr.cross_impute_ready.basic_annotation.vcf.gz"
cross_impute_ready_vcf_trypanogen=$X_ready_dir_trypanogen/trypanogen.$site_name."vqsr.cross_impute_ready.basic_annotation.vcf.gz"

genotype_gvcfs_vcf_baylor=$X_ready_dir_baylor/baylor.$site_name".basic_annotation.vcf.gz"
genotype_gvcfs_vcf_sahgp=$X_ready_dir_sahgp/sahgp.$site_name".basic_annotation.vcf.gz"
genotype_gvcfs_vcf_trypanogen=$X_ready_dir_trypanogen/trypanogen.$site_name".basic_annotation.vcf.gz"
 
post_vqsr_union_vcf=$phasing_ready_dir/$site_name.post-vqsr.sites.vcf.gz
post_vqsr_union_tbi=$phasing_ready_dir/$site_name.post-vqsr.sites.vcf.gz.tbi

pre_vqsr_union_vcf=$phasing_ready_dir/$site_name.pre-vqsr.vcf.gz
pre_vqsr_union_tbi=$phasing_ready_dir/$site_name.pre-vqsr.vcf.gz.tbi

# Setting a vcf here. In the job script it will be created as .gz.
pre_vqsr_union_replace_missing_vcf=$phasing_ready_dir/$site_name.pre-vqsr.replaced_missing_with_refref.vcf.gz
pre_vqsr_union_replace_missing_tbi=$phasing_ready_dir/$site_name.pre-vqsr.replaced_missing_with_refref.vcf.gz.tbi

if [ ! -f $post_vqsr_union_tbi ]; then
  get_union_post_vqsr_cmd="qsub -N gupov.$site_name -o $logs_dir/get_union_post_vqsr.$site_name.o -e $logs_dir/get_union_post_vqsr.$site_name.e -v config=$config,cross_impute_ready_vcf_baylor=$cross_impute_ready_vcf_baylor,cross_impute_ready_vcf_sahgp=$cross_impute_ready_vcf_sahgp,cross_impute_ready_vcf_trypanogen=$cross_impute_ready_vcf_trypanogen,post_vqsr_union_vcf=$post_vqsr_union_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$combine_variants_threads -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_post_vqsr.single.sh"

  if [ $DEBUG -eq 1 ]; then
    echo $get_union_post_vqsr_cmd
  else 
    get_union_post_vqsr_job_id=`eval $get_union_post_vqsr_cmd`
    echo "get_union_post_vqsr: site: $site_name, get_union_post_vqsr_job_id: $get_union_post_vqsr_job_id"
    echo ${get_union_post_vqsr_cmd} > $logs_dir/get_union_post_vqsr.$site_name.$get_union_post_vqsr_job_id.qsub
    cat get_union_post_vqsr.single.sh > $logs_dir/get_union_post_vqsr.$site_name.$get_union_post_vqsr_job_id.sh
    cat $config > $logs_dir/get_union_post_vqsr.$site_name.$get_union_post_vqsr_job_id.config
  
    qalter -o $logs_dir/get_union_post_vqsr.$site_name.$get_union_post_vqsr_job_id.o $get_union_post_vqsr_job_id
    qalter -e $logs_dir/get_union_post_vqsr.$site_name.$get_union_post_vqsr_job_id.e $get_union_post_vqsr_job_id
  fi

   get_union_pre_vqsr_cmd="qsub -W depend=afterok:$get_union_post_vqsr_job_id -N guprev.$site_name -o $logs_dir/get_union_pre_vqsr.$site_name.o -e $logs_dir/get_union_pre_vqsr.$site_name.e -v config=$config,genotype_gvcfs_vcf_baylor=$genotype_gvcfs_vcf_baylor,genotype_gvcfs_vcf_sahgp=$genotype_gvcfs_vcf_sahgp,genotype_gvcfs_vcf_trypanogen=$genotype_gvcfs_vcf_trypanogen,post_vqsr_union_vcf=$post_vqsr_union_vcf,pre_vqsr_union_vcf=$pre_vqsr_union_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$combine_variants_threads -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_pre_vqsr.single.sh"

  if [ $DEBUG -eq 1 ]; then
    echo $get_union_pre_vqsr_cmd
  else
    get_union_pre_vqsr_job_id=`eval $get_union_pre_vqsr_cmd`
    echo "get_union_pre_vqsr: site: $site_name, get_union_pre_vqsr_job_id: $get_union_pre_vqsr_job_id"
    echo ${get_union_pre_vqsr_cmd} > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.qsub
    cat get_union_pre_vqsr.single.sh > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.sh
    cat $config > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.config

    qalter -o $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.o $get_union_pre_vqsr_job_id
    qalter -e $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.e $get_union_pre_vqsr_job_id
  fi

  get_union_pre_vqsr_replace_missing_cmd="qsub -W depend=afterok:$get_union_pre_vqsr_job_id -N guprevrm.$site_name -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.o -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.e -v config=$config,pre_vqsr_union_vcf=$pre_vqsr_union_vcf,pre_vqsr_union_replace_missing_vcf=$pre_vqsr_union_replace_missing_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=1 -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_pre_vqsr_replace_missing.single.sh"

  if [ $DEBUG -eq 1 ]; then
    echo $get_union_pre_vqsr_replace_missing_cmd
  else
    get_union_pre_vqsr_replace_missing_job_id=`eval $get_union_pre_vqsr_replace_missing_cmd`
    echo "get_union_pre_vqsr_replace_missing site: $site_name, get_union_pre_vqsr_replace_missing_job_id: $get_union_pre_vqsr_replace_missing_job_id"
    echo ${get_union_pre_vqsr_replace_missing_cmd} > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.qsub
    cat get_union_pre_vqsr_replace_missing.single.sh > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.sh
    cat $config > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.config

    qalter -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.o $get_union_pre_vqsr_replace_missing_job_id
    qalter -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.e $get_union_pre_vqsr_replace_missing_job_id
  fi
# if post_vqsr_union has been created just go on with pre_vqsr_union
elif [ ! -f $pre_vqsr_union_tbi ]; then
  get_union_pre_vqsr_cmd="qsub -N guprev.$site_name -o $logs_dir/get_union_pre_vqsr.$site_name.o -e $logs_dir/get_union_pre_vqsr.$site_name.e -v config=$config,genotype_gvcfs_vcf_baylor=$genotype_gvcfs_vcf_baylor,genotype_gvcfs_vcf_sahgp=$genotype_gvcfs_vcf_sahgp,genotype_gvcfs_vcf_trypanogen=$genotype_gvcfs_vcf_trypanogen,post_vqsr_union_vcf=$post_vqsr_union_vcf,pre_vqsr_union_vcf=$pre_vqsr_union_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$combine_variants_threads -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_pre_vqsr.single.sh"

  if [ $DEBUG -eq 1 ]; then
    echo $get_union_pre_vqsr_cmd
  else
    get_union_pre_vqsr_job_id=`eval $get_union_pre_vqsr_cmd`
    echo "get_union_pre_vqsr: site: $site_name, get_union_pre_vqsr_job_id: $get_union_pre_vqsr_job_id"
    echo ${get_union_pre_vqsr_cmd} > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.qsub
    cat get_union_pre_vqsr.single.sh > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.sh
    cat $config > $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.config

    qalter -o $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.o $get_union_pre_vqsr_job_id
    qalter -e $logs_dir/get_union_pre_vqsr.$site_name.$get_union_pre_vqsr_job_id.e $get_union_pre_vqsr_job_id
  fi
  
  get_union_pre_vqsr_replace_missing_cmd="qsub -W depend=afterok:$get_union_pre_vqsr_job_id -N guprevrm.$site_name -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.o -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.e -v config=$config,pre_vqsr_union_vcf=$pre_vqsr_union_vcf,pre_vqsr_union_replace_missing_vcf=$pre_vqsr_union_replace_missing_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=1 -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_pre_vqsr_replace_missing.single.sh"

  if [ $DEBUG -eq 1 ]; then
    echo $get_union_pre_vqsr_replace_missing_cmd
  else
    get_union_pre_vqsr_replace_missing_job_id=`eval $get_union_pre_vqsr_replace_missing_cmd`
    echo "get_union_pre_vqsr_replace_missing site: $site_name, get_union_pre_vqsr_replace_missing_job_id: $get_union_pre_vqsr_replace_missing_job_id"
    echo ${get_union_pre_vqsr_replace_missing_cmd} > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.qsub
    cat get_union_pre_vqsr_replace_missing.single.sh > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.sh
    cat $config > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.config

    qalter -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.o $get_union_pre_vqsr_replace_missing_job_id
    qalter -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.e $get_union_pre_vqsr_replace_missing_job_id
  fi
elif [ ! -f $pre_vqsr_union_replace_missing_tbi ]; then 
# if pre_vqsr_union has been created just go on with pre_vqsr_union_replace_missing_vcf
  get_union_pre_vqsr_replace_missing_cmd="qsub -n guprevrm.$site_name -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.o -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.e -v config=$config,pre_vqsr_union_vcf=$pre_vqsr_union_vcf,pre_vqsr_union_replace_missing_vcf=$pre_vqsr_union_replace_missing_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=1 -l walltime=$gatk_combine_variants_walltime -M $pbs_status_mailto -m abe get_union_pre_vqsr_replace_missing.single.sh"

  if [ $DEBUG -eq 1 ]; then
    echo $get_union_pre_vqsr_replace_missing_cmd
  else
    get_union_pre_vqsr_replace_missing_job_id=`eval $get_union_pre_vqsr_replace_missing_cmd`
    echo "get_union_pre_vqsr_replace_missing site: $site_name, get_union_pre_vqsr_replace_missing_job_id: $get_union_pre_vqsr_replace_missing_job_id"
    echo ${get_union_pre_vqsr_replace_missing_cmd} > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.qsub
    cat get_union_pre_vqsr_replace_missing.single.sh > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.sh
    cat $config > $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.config

    qalter -o $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.o $get_union_pre_vqsr_replace_missing_job_id
    qalter -e $logs_dir/get_union_pre_vqsr_replace_missing.$site_name.$get_union_pre_vqsr_replace_missing_job_id.e $get_union_pre_vqsr_replace_missing_job_id
  fi
  #echo "$pre_vqsr_union_replace_missing_vcf, site:$site_name has already been created" 
  echo "All .tbis for site:$site_name have been created" 
fi




