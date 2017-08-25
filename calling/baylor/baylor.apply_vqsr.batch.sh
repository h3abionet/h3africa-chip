#!/bin/bash
DEBUG=0

queue=batch
config=/home/gerrit/projects/chipdesign/variant_calling/baylor/dm/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

tmp_dir=$tmp_dir

genotype_gvcfs_dir=$genotype_gvcfs_dir
vqsr_dir=$vqsr_dir
apply_vqsr_dir=$apply_vqsr_dir
cohort=$cohort
logs_dir=$logs_dir"/apply_vqsr."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

gatk_apply_vqsr_threads=$(( $gatk_vqsr_data_threads*$gatk_vqsr_cpu_threads_per_data_thread ))

# Apply VQSR the autosomes
for i in {1..22}; do 
  site="-L "$i
  site_name=$i

  genotyped_vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"
  
  vqsr_snps_recal=$vqsr_dir/$cohort.$site_name."vcf.vqsr.recal" 
  vqsr_snps_tranches=$vqsr_dir/$cohort.$site_name."vcf.vqsr.tranches" 
  
  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"
  apply_vqsr_tbi=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz.tbi"
 
  if [ ! -f $apply_vqsr_tbi ]; then
    apply_vqsr_cmd="qsub -N baylor.apply_vqsr.$site_name -o $logs_dir/baylor.apply_vqsr.$site_name.o -e $logs_dir/baylor.apply_vqsr.$site_name.e -v config=$config,genotyped_vcf=$genotyped_vcf,apply_vqsr_vcf=$apply_vqsr_vcf,site=\"$site\",vqsr_snps_recal=$vqsr_snps_recal,vqsr_snps_tranches=$vqsr_snps_tranches -q $queue -l nodes=1:ppn=$gatk_apply_vqsr_threads -l walltime=$gatk_apply_vqsr_walltime -M $pbs_status_mailto -m abe baylor.apply_vqsr.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $apply_vqsr_cmd
    else 
      apply_vqsr_job_id=`eval $apply_vqsr_cmd`
      echo "Baylor: site: $site_name, apply_vqsr_job_id: $apply_vqsr_job_id"
      echo ${apply_vqsr_cmd} > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.qsub
      cat baylor.apply_vqsr.single.sh > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.sh
      cat $config > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.config
    
      qalter -o $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.o $apply_vqsr_job_id
      qalter -e $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.e $apply_vqsr_job_id
    fi
  else
    echo "$pply_vqsr_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
done

# Males
x_par1="X:60001-2699520"
x_par2="X:154931044-155260560"
y_par1="Y:10001-2649520"
y_par2="Y:59034050-59363566"

## X_PAR1
site="-L "$x_par1
site_name="X_PAR1"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  genotyped_vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"

  vqsr_snps_recal=$vqsr_dir/$cohort.$site_name."vcf.vqsr.recal"
  vqsr_snps_tranches=$vqsr_dir/$cohort.$site_name."vcf.vqsr.tranches"

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"
  apply_vqsr_tbi=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz.tbi"

  if [ ! -f $apply_vqsr_tbi ]; then
    apply_vqsr_cmd="qsub -N baylor.apply_vqsr.$site_name -o $logs_dir/baylor.apply_vqsr.$site_name.o -e $logs_dir/baylor.apply_vqsr.$site_name.e -v config=$config,genotyped_vcf=$genotyped_vcf,apply_vqsr_vcf=$apply_vqsr_vcf,site=\"$site\",vqsr_snps_recal=$vqsr_snps_recal,vqsr_snps_tranches=$vqsr_snps_tranches -q $queue -l nodes=1:ppn=$gatk_apply_vqsr_threads -l walltime=$gatk_apply_vqsr_walltime -M $pbs_status_mailto -m abe baylor.apply_vqsr.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $apply_vqsr_cmd
    else
      apply_vqsr_job_id=`eval $apply_vqsr_cmd`
      echo "Baylor: site: $site_name, apply_vqsr_job_id: $apply_vqsr_job_id"
      echo ${apply_vqsr_cmd} > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.qsub
      cat baylor.apply_vqsr.single.sh > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.sh
      cat $config > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.config

      qalter -o $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.o $apply_vqsr_job_id
      qalter -e $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.e $apply_vqsr_job_id
    fi
  else
    echo "$pply_vqsr_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## X_PAR2
site="-L "$x_par2
site_name="X_PAR2"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  genotyped_vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"

  vqsr_snps_recal=$vqsr_dir/$cohort.$site_name."vcf.vqsr.recal"
  vqsr_snps_tranches=$vqsr_dir/$cohort.$site_name."vcf.vqsr.tranches"

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"
  apply_vqsr_tbi=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz.tbi"

  if [ ! -f $apply_vqsr_tbi ]; then
    apply_vqsr_cmd="qsub -N baylor.apply_vqsr.$site_name -o $logs_dir/baylor.apply_vqsr.$site_name.o -e $logs_dir/baylor.apply_vqsr.$site_name.e -v config=$config,genotyped_vcf=$genotyped_vcf,apply_vqsr_vcf=$apply_vqsr_vcf,site=\"$site\",vqsr_snps_recal=$vqsr_snps_recal,vqsr_snps_tranches=$vqsr_snps_tranches -q $queue -l nodes=1:ppn=$gatk_apply_vqsr_threads -l walltime=$gatk_apply_vqsr_walltime -M $pbs_status_mailto -m abe baylor.apply_vqsr.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $apply_vqsr_cmd
    else
      apply_vqsr_job_id=`eval $apply_vqsr_cmd`
      echo "Baylor: site: $site_name, apply_vqsr_job_id: $apply_vqsr_job_id"
      echo ${apply_vqsr_cmd} > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.qsub
      cat baylor.apply_vqsr.single.sh > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.sh
      cat $config > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.config

      qalter -o $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.o $apply_vqsr_job_id
      qalter -e $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.e $apply_vqsr_job_id
    fi
  else
    echo "$pply_vqsr_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## X_nonPAR
site="-L X -XL "$x_par1" -XL "$x_par2
site_name="X_nonPAR"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  genotyped_vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"

  vqsr_snps_recal=$vqsr_dir/$cohort.$site_name."vcf.vqsr.recal"
  vqsr_snps_tranches=$vqsr_dir/$cohort.$site_name."vcf.vqsr.tranches"

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"
  apply_vqsr_tbi=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz.tbi"

  if [ ! -f $apply_vqsr_tbi ]; then
    apply_vqsr_cmd="qsub -N baylor.apply_vqsr.$site_name -o $logs_dir/baylor.apply_vqsr.$site_name.o -e $logs_dir/baylor.apply_vqsr.$site_name.e -v config=$config,genotyped_vcf=$genotyped_vcf,apply_vqsr_vcf=$apply_vqsr_vcf,site=\"$site\",vqsr_snps_recal=$vqsr_snps_recal,vqsr_snps_tranches=$vqsr_snps_tranches -q $queue -l nodes=1:ppn=$gatk_apply_vqsr_threads -l walltime=$gatk_apply_vqsr_walltime -M $pbs_status_mailto -m abe baylor.apply_vqsr.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $apply_vqsr_cmd
    else
      apply_vqsr_job_id=`eval $apply_vqsr_cmd`
      echo "Baylor: site: $site_name, apply_vqsr_job_id: $apply_vqsr_job_id"
      echo ${apply_vqsr_cmd} > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.qsub
      cat baylor.apply_vqsr.single.sh > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.sh
      cat $config > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.config

      qalter -o $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.o $apply_vqsr_job_id
      qalter -e $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.e $apply_vqsr_job_id
    fi
  else
    echo "$pply_vqsr_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## Y_PAR1
site="-L "$y_par1
site_name="Y_PAR1"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  genotyped_vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"

  vqsr_snps_recal=$vqsr_dir/$cohort.$site_name."vcf.vqsr.recal"
  vqsr_snps_tranches=$vqsr_dir/$cohort.$site_name."vcf.vqsr.tranches"

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"
  apply_vqsr_tbi=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz.tbi"

  if [ ! -f $apply_vqsr_tbi ]; then
    apply_vqsr_cmd="qsub -N baylor.apply_vqsr.$site_name -o $logs_dir/baylor.apply_vqsr.$site_name.o -e $logs_dir/baylor.apply_vqsr.$site_name.e -v config=$config,genotyped_vcf=$genotyped_vcf,apply_vqsr_vcf=$apply_vqsr_vcf,site=\"$site\",vqsr_snps_recal=$vqsr_snps_recal,vqsr_snps_tranches=$vqsr_snps_tranches -q $queue -l nodes=1:ppn=$gatk_apply_vqsr_threads -l walltime=$gatk_apply_vqsr_walltime -M $pbs_status_mailto -m abe baylor.apply_vqsr.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $apply_vqsr_cmd
    else
      apply_vqsr_job_id=`eval $apply_vqsr_cmd`
      echo "Baylor: site: $site_name, apply_vqsr_job_id: $apply_vqsr_job_id"
      echo ${apply_vqsr_cmd} > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.qsub
      cat baylor.apply_vqsr.single.sh > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.sh
      cat $config > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.config

      qalter -o $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.o $apply_vqsr_job_id
      qalter -e $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.e $apply_vqsr_job_id
    fi
  else
    echo "$pply_vqsr_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## Y_PAR2
site="-L "$y_par2
site_name="Y_PAR2"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  genotyped_vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"

  vqsr_snps_recal=$vqsr_dir/$cohort.$site_name."vcf.vqsr.recal"
  vqsr_snps_tranches=$vqsr_dir/$cohort.$site_name."vcf.vqsr.tranches"

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"
  apply_vqsr_tbi=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz.tbi"

  if [ ! -f $apply_vqsr_tbi ]; then
    apply_vqsr_cmd="qsub -N baylor.apply_vqsr.$site_name -o $logs_dir/baylor.apply_vqsr.$site_name.o -e $logs_dir/baylor.apply_vqsr.$site_name.e -v config=$config,genotyped_vcf=$genotyped_vcf,apply_vqsr_vcf=$apply_vqsr_vcf,site=\"$site\",vqsr_snps_recal=$vqsr_snps_recal,vqsr_snps_tranches=$vqsr_snps_tranches -q $queue -l nodes=1:ppn=$gatk_apply_vqsr_threads -l walltime=$gatk_apply_vqsr_walltime -M $pbs_status_mailto -m abe baylor.apply_vqsr.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $apply_vqsr_cmd
    else
      apply_vqsr_job_id=`eval $apply_vqsr_cmd`
      echo "Baylor: site: $site_name, apply_vqsr_job_id: $apply_vqsr_job_id"
      echo ${apply_vqsr_cmd} > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.qsub
      cat baylor.apply_vqsr.single.sh > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.sh
      cat $config > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.config

      qalter -o $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.o $apply_vqsr_job_id
      qalter -e $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.e $apply_vqsr_job_id
    fi
  else
    echo "$pply_vqsr_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## Y_nonPAR
site="-L Y -XL "$y_par1" -XL "$y_par2
site_name="Y_nonPAR"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  genotyped_vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"

  vqsr_snps_recal=$vqsr_dir/$cohort.$site_name."vcf.vqsr.recal"
  vqsr_snps_tranches=$vqsr_dir/$cohort.$site_name."vcf.vqsr.tranches"

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"
  apply_vqsr_tbi=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz.tbi"

  if [ ! -f $apply_vqsr_tbi ]; then
    apply_vqsr_cmd="qsub -N baylor.apply_vqsr.$site_name -o $logs_dir/baylor.apply_vqsr.$site_name.o -e $logs_dir/baylor.apply_vqsr.$site_name.e -v config=$config,genotyped_vcf=$genotyped_vcf,apply_vqsr_vcf=$apply_vqsr_vcf,site=\"$site\",vqsr_snps_recal=$vqsr_snps_recal,vqsr_snps_tranches=$vqsr_snps_tranches -q $queue -l nodes=1:ppn=$gatk_apply_vqsr_threads -l walltime=$gatk_apply_vqsr_walltime -M $pbs_status_mailto -m abe baylor.apply_vqsr.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $apply_vqsr_cmd
    else
      apply_vqsr_job_id=`eval $apply_vqsr_cmd`
      echo "Baylor: site: $site_name, apply_vqsr_job_id: $apply_vqsr_job_id"
      echo ${apply_vqsr_cmd} > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.qsub
      cat baylor.apply_vqsr.single.sh > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.sh
      cat $config > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.config

      qalter -o $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.o $apply_vqsr_job_id
      qalter -e $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.e $apply_vqsr_job_id
    fi
  else
    echo "$pply_vqsr_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

# Females
## X
site="-L X"
site_name="X"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  genotyped_vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"

  vqsr_snps_recal=$vqsr_dir/$cohort.$site_name."vcf.vqsr.recal"
  vqsr_snps_tranches=$vqsr_dir/$cohort.$site_name."vcf.vqsr.tranches"

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"
  apply_vqsr_tbi=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz.tbi"

  if [ ! -f $apply_vqsr_tbi ]; then
    apply_vqsr_cmd="qsub -N baylor.apply_vqsr.$site_name -o $logs_dir/baylor.apply_vqsr.$site_name.o -e $logs_dir/baylor.apply_vqsr.$site_name.e -v config=$config,genotyped_vcf=$genotyped_vcf,apply_vqsr_vcf=$apply_vqsr_vcf,site=\"$site\",vqsr_snps_recal=$vqsr_snps_recal,vqsr_snps_tranches=$vqsr_snps_tranches -q $queue -l nodes=1:ppn=$gatk_apply_vqsr_threads -l walltime=$gatk_apply_vqsr_walltime -M $pbs_status_mailto -m abe baylor.apply_vqsr.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $apply_vqsr_cmd
    else
      apply_vqsr_job_id=`eval $apply_vqsr_cmd`
      echo "Baylor: site: $site_name, apply_vqsr_job_id: $apply_vqsr_job_id"
      echo ${apply_vqsr_cmd} > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.qsub
      cat baylor.apply_vqsr.single.sh > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.sh
      cat $config > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.config

      qalter -o $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.o $apply_vqsr_job_id
      qalter -e $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.e $apply_vqsr_job_id
    fi
  else
    echo "$pply_vqsr_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No females in cohort:$cohort";
fi

# M
site="-L MT"
site_name="MT"

genotyped_vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"

vqsr_snps_recal=$vqsr_dir/$cohort.$site_name."vcf.vqsr.recal"
vqsr_snps_tranches=$vqsr_dir/$cohort.$site_name."vcf.vqsr.tranches"

apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"
apply_vqsr_tbi=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz.tbi"

if [ ! -f $apply_vqsr_tbi ]; then
  apply_vqsr_cmd="qsub -N baylor.apply_vqsr.$site_name -o $logs_dir/baylor.apply_vqsr.$site_name.o -e $logs_dir/baylor.apply_vqsr.$site_name.e -v config=$config,genotyped_vcf=$genotyped_vcf,apply_vqsr_vcf=$apply_vqsr_vcf,site=\"$site\",vqsr_snps_recal=$vqsr_snps_recal,vqsr_snps_tranches=$vqsr_snps_tranches -q $queue -l nodes=1:ppn=$gatk_apply_vqsr_threads -l walltime=$gatk_apply_vqsr_walltime -M $pbs_status_mailto -m abe baylor.apply_vqsr.single.sh"

  if [ $DEBUG -eq 1 ]; then
    echo $apply_vqsr_cmd
  else
    apply_vqsr_job_id=`eval $apply_vqsr_cmd`
    echo "Baylor: site: $site_name, apply_vqsr_job_id: $apply_vqsr_job_id"
    echo ${apply_vqsr_cmd} > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.qsub
    cat baylor.apply_vqsr.single.sh > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.sh
    cat $config > $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.config

    qalter -o $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.o $apply_vqsr_job_id
    qalter -e $logs_dir/baylor.apply_vqsr.$site_name.$apply_vqsr_job_id.e $apply_vqsr_job_id
  fi
else
  echo "$pply_vqsr_vcf for cohort:$cohort, site:$site_name has already been created" 
fi
