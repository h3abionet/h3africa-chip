#!/bin/bash
DEBUG=0

queue=batch
config=/home/gerrit/projects/chipdesign/variant_calling/sahgp/dm/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

tmp_dir=$tmp_dir

genotype_gvcfs_dir=$genotype_gvcfs_dir

apply_vqsr_dir=$apply_vqsr_dir
cross_impute__ready_dir=$cross_impute_ready_dir
cohort=$cohort
logs_dir=$logs_dir"/prepare_for_cross_impute."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

# Not running threaded at the moment but might later, so keeping this in.

prepare_cross_impute_threads=$(( $gatk_prepare_cross_impute_data_threads*$gatk_prepare_cross_impute_cpu_threads_per_data_thread ))

# Get autosomes ready for cross imputation
for i in {1..22}; do 
  site_name=$i
  site="-L "$i

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  cross_impute_ready_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"

  if [ ! -f $cross_impute_ready_tbi ]; then
    prepare_cross_impute_cmd="qsub -N sahgp.pci.$site_name -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.o -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.e -v config=$config,apply_vqsr_vcf=$apply_vqsr_vcf,cross_impute_ready_vcf=$cross_impute_ready_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$prepare_cross_impute_threads -l walltime=$prepare_cross_impute_walltime -M $pbs_status_mailto -m abe sahgp.prepare_for_cross_impute.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $prepare_cross_impute_cmd
    else 
      prepare_cross_impute_job_id=`eval $prepare_cross_impute_cmd`
      echo "SAHGP: site: $site_name, prepare_cross_impute_job_id: $prepare_cross_impute_job_id"
      echo ${prepare_cross_impute_cmd} > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.qsub
      cat sahgp.prepare_for_cross_impute.single.sh > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.sh
      cat $config > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.config
    
      qalter -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.o $prepare_cross_impute_job_id
      qalter -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.e $prepare_cross_impute_job_id
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

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  cross_impute_ready_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"

  if [ ! -f $cross_impute_ready_tbi ]; then
    prepare_cross_impute_cmd="qsub -N sahgp.pci.$site_name -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.o -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.e -v config=$config,apply_vqsr_vcf=$apply_vqsr_vcf,cross_impute_ready_vcf=$cross_impute_ready_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$prepare_cross_impute_threads -l walltime=$prepare_cross_impute_walltime -M $pbs_status_mailto -m abe sahgp.prepare_for_cross_impute.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $prepare_cross_impute_cmd
    else 
      prepare_cross_impute_job_id=`eval $prepare_cross_impute_cmd`
      echo "SAHGP: site: $site_name, prepare_cross_impute_job_id: $prepare_cross_impute_job_id"
      echo ${prepare_cross_impute_cmd} > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.qsub
      cat sahgp.prepare_for_cross_impute.single.sh > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.sh
      cat $config > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.config
    
      qalter -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.o $prepare_cross_impute_job_id
      qalter -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.e $prepare_cross_impute_job_id
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

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  cross_impute_ready_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"

  if [ ! -f $cross_impute_ready_tbi ]; then
    prepare_cross_impute_cmd="qsub -N sahgp.pci.$site_name -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.o -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.e -v config=$config,apply_vqsr_vcf=$apply_vqsr_vcf,cross_impute_ready_vcf=$cross_impute_ready_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$prepare_cross_impute_threads -l walltime=$prepare_cross_impute_walltime -M $pbs_status_mailto -m abe sahgp.prepare_for_cross_impute.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $prepare_cross_impute_cmd
    else 
      prepare_cross_impute_job_id=`eval $prepare_cross_impute_cmd`
      echo "SAHGP: site: $site_name, prepare_cross_impute_job_id: $prepare_cross_impute_job_id"
      echo ${prepare_cross_impute_cmd} > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.qsub
      cat sahgp.prepare_for_cross_impute.single.sh > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.sh
      cat $config > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.config
    
      qalter -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.o $prepare_cross_impute_job_id
      qalter -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.e $prepare_cross_impute_job_id
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

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  cross_impute_ready_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"

  if [ ! -f $cross_impute_ready_tbi ]; then
    prepare_cross_impute_cmd="qsub -N sahgp.pci.$site_name -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.o -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.e -v config=$config,apply_vqsr_vcf=$apply_vqsr_vcf,cross_impute_ready_vcf=$cross_impute_ready_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$prepare_cross_impute_threads -l walltime=$prepare_cross_impute_walltime -M $pbs_status_mailto -m abe sahgp.prepare_for_cross_impute.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $prepare_cross_impute_cmd
    else 
      prepare_cross_impute_job_id=`eval $prepare_cross_impute_cmd`
      echo "SAHGP: site: $site_name, prepare_cross_impute_job_id: $prepare_cross_impute_job_id"
      echo ${prepare_cross_impute_cmd} > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.qsub
      cat sahgp.prepare_for_cross_impute.single.sh > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.sh
      cat $config > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.config
    
      qalter -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.o $prepare_cross_impute_job_id
      qalter -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.e $prepare_cross_impute_job_id
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

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  cross_impute_ready_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"

  if [ ! -f $cross_impute_ready_tbi ]; then
    prepare_cross_impute_cmd="qsub -N sahgp.pci.$site_name -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.o -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.e -v config=$config,apply_vqsr_vcf=$apply_vqsr_vcf,cross_impute_ready_vcf=$cross_impute_ready_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$prepare_cross_impute_threads -l walltime=$prepare_cross_impute_walltime -M $pbs_status_mailto -m abe sahgp.prepare_for_cross_impute.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $prepare_cross_impute_cmd
    else 
      prepare_cross_impute_job_id=`eval $prepare_cross_impute_cmd`
      echo "SAHGP: site: $site_name, prepare_cross_impute_job_id: $prepare_cross_impute_job_id"
      echo ${prepare_cross_impute_cmd} > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.qsub
      cat sahgp.prepare_for_cross_impute.single.sh > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.sh
      cat $config > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.config
    
      qalter -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.o $prepare_cross_impute_job_id
      qalter -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.e $prepare_cross_impute_job_id
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

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  cross_impute_ready_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"

  if [ ! -f $cross_impute_ready_tbi ]; then
    prepare_cross_impute_cmd="qsub -N sahgp.pci.$site_name -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.o -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.e -v config=$config,apply_vqsr_vcf=$apply_vqsr_vcf,cross_impute_ready_vcf=$cross_impute_ready_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$prepare_cross_impute_threads -l walltime=$prepare_cross_impute_walltime -M $pbs_status_mailto -m abe sahgp.prepare_for_cross_impute.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $prepare_cross_impute_cmd
    else 
      prepare_cross_impute_job_id=`eval $prepare_cross_impute_cmd`
      echo "SAHGP: site: $site_name, prepare_cross_impute_job_id: $prepare_cross_impute_job_id"
      echo ${prepare_cross_impute_cmd} > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.qsub
      cat sahgp.prepare_for_cross_impute.single.sh > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.sh
      cat $config > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.config
    
      qalter -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.o $prepare_cross_impute_job_id
      qalter -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.e $prepare_cross_impute_job_id
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

  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  cross_impute_ready_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"

  if [ ! -f $cross_impute_ready_tbi ]; then
    prepare_cross_impute_cmd="qsub -N sahgp.pci.$site_name -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.o -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.e -v config=$config,apply_vqsr_vcf=$apply_vqsr_vcf,cross_impute_ready_vcf=$cross_impute_ready_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$prepare_cross_impute_threads -l walltime=$prepare_cross_impute_walltime -M $pbs_status_mailto -m abe sahgp.prepare_for_cross_impute.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $prepare_cross_impute_cmd
    else 
      prepare_cross_impute_job_id=`eval $prepare_cross_impute_cmd`
      echo "SAHGP: site: $site_name, prepare_cross_impute_job_id: $prepare_cross_impute_job_id"
      echo ${prepare_cross_impute_cmd} > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.qsub
      cat sahgp.prepare_for_cross_impute.single.sh > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.sh
      cat $config > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.config
    
      qalter -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.o $prepare_cross_impute_job_id
      qalter -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.e $prepare_cross_impute_job_id
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
  apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  cross_impute_ready_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"

  if [ ! -f $cross_impute_ready_tbi ]; then
    prepare_cross_impute_cmd="qsub -N sahgp.pci.$site_name -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.o -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.e -v config=$config,apply_vqsr_vcf=$apply_vqsr_vcf,cross_impute_ready_vcf=$cross_impute_ready_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$prepare_cross_impute_threads -l walltime=$prepare_cross_impute_walltime -M $pbs_status_mailto -m abe sahgp.prepare_for_cross_impute.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $prepare_cross_impute_cmd
    else 
      prepare_cross_impute_job_id=`eval $prepare_cross_impute_cmd`
      echo "SAHGP: site: $site_name, prepare_cross_impute_job_id: $prepare_cross_impute_job_id"
      echo ${prepare_cross_impute_cmd} > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.qsub
      cat sahgp.prepare_for_cross_impute.single.sh > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.sh
      cat $config > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.config
    
      qalter -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.o $prepare_cross_impute_job_id
      qalter -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.e $prepare_cross_impute_job_id
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

apply_vqsr_vcf=$apply_vqsr_dir/$cohort.$site_name."vqsr.vcf.gz"

cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
cross_impute_ready_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"

if [ ! -f $cross_impute_ready_tbi ]; then
  prepare_cross_impute_cmd="qsub -N sahgp.pci.$site_name -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.o -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.e -v config=$config,apply_vqsr_vcf=$apply_vqsr_vcf,cross_impute_ready_vcf=$cross_impute_ready_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$prepare_cross_impute_threads -l walltime=$prepare_cross_impute_walltime -M $pbs_status_mailto -m abe sahgp.prepare_for_cross_impute.single.sh"
 
  if [ $DEBUG -eq 1 ]; then
    echo $prepare_cross_impute_cmd
  else 
    prepare_cross_impute_job_id=`eval $prepare_cross_impute_cmd`
    echo "SAHGP: site: $site_name, prepare_cross_impute_job_id: $prepare_cross_impute_job_id"
    echo ${prepare_cross_impute_cmd} > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.qsub
    cat sahgp.prepare_for_cross_impute.single.sh > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.sh
    cat $config > $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.config
    
    qalter -o $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.o $prepare_cross_impute_job_id
    qalter -e $logs_dir/sahgp.prepare_for_cross_impute.$site_name.$prepare_cross_impute_job_id.e $prepare_cross_impute_job_id
  fi
else
  echo "$pply_vqsr_vcf for cohort:$cohort, site:$site_name has already been created" 
fi
