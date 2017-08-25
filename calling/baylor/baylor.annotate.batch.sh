#!/bin/bash
DEBUG=0

queue=batch
config=/home/gerrit/projects/chipdesign/variant_calling/baylor/dm/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

tmp_dir=$tmp_dir

genotype_gvcfs_dir=$genotype_gvcfs_dir

cross_impute_ready_dir=$cross_impute_ready_dir
annotate_dir=$annotate_dir
cohort=$cohort
logs_dir=$logs_dir"/annotate."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

# Not running threaded at the moment but might later, so keeping this in.

annotate_threads=$(( $gatk_annotate_data_threads*$gatk_annotate_cpu_threads_per_data_thread ))

# Get autosomes ready for annotation
for i in {1..22}; do 
  site_name=$i
  site="-L "$i

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  annotate_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"
  
  annotate_vcf=$annotate_dir/$cohort.$site_name."annotate.vcf.gz"
  annotate_tbi=$annotate_dir/$cohort.$site_name."annotate.vcf.gz.tbi"

  if [ ! -f $annotate_tbi ]; then
    annotate_cmd="qsub -N baylor.an.$site_name -o $logs_dir/baylor.annotate.$site_name.o -e $logs_dir/baylor.annotate.$site_name.e -v config=$config,cross_impute_ready_vcf=$cross_impute_ready_vcf,annotate_vcf=$annotate_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$annotate_threads -l walltime=$annotate_walltime -M $pbs_status_mailto -m abe baylor.annotate.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $annotate_cmd
    else 
      annotate_job_id=`eval $annotate_cmd`
      echo "Baylor: site: $site_name, annotate_job_id: $annotate_job_id"
      echo ${annotate_cmd} > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.qsub
      cat baylor.annotate.single.sh > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.sh
      cat $config > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.config
    
      qalter -o $logs_dir/baylor.annotate.$site_name.$annotate_job_id.o $annotate_job_id
      qalter -e $logs_dir/baylor.annotate.$site_name.$annotate_job_id.e $annotate_job_id
    fi
  else
    echo "$annotate_vcf for cohort:$cohort, site:$site_name has already been created" 
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

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  annotate_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"
  
  annotate_vcf=$annotate_dir/$cohort.$site_name."annotate.vcf.gz"
  annotate_tbi=$annotate_dir/$cohort.$site_name."annotate.vcf.gz.tbi"

   if [ ! -f $annotate_tbi ]; then
    annotate_cmd="qsub -N baylor.an.$site_name -o $logs_dir/baylor.annotate.$site_name.o -e $logs_dir/baylor.annotate.$site_name.e -v config=$config,cross_impute_ready_vcf=$cross_impute_ready_vcf,annotate_vcf=$annotate_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$annotate_threads -l walltime=$annotate_walltime -M $pbs_status_mailto -m abe baylor.annotate.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $annotate_cmd
    else 
      annotate_job_id=`eval $annotate_cmd`
      echo "Baylor: site: $site_name, annotate_job_id: $annotate_job_id"
      echo ${annotate_cmd} > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.qsub
      cat baylor.annotate.single.sh > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.sh
      cat $config > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.config
    
      qalter -o $logs_dir/baylor.annotate.$site_name.$annotate_job_id.o $annotate_job_id
      qalter -e $logs_dir/baylor.annotate.$site_name.$annotate_job_id.e $annotate_job_id
    fi
  else
    echo "$annotate_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## X_PAR2
site="-L "$x_par2
site_name="X_PAR2"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  annotate_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"
  
  annotate_vcf=$annotate_dir/$cohort.$site_name."annotate.vcf.gz"
  annotate_tbi=$annotate_dir/$cohort.$site_name."annotate.vcf.gz.tbi"

  if [ ! -f $annotate_tbi ]; then
    annotate_cmd="qsub -N baylor.an.$site_name -o $logs_dir/baylor.annotate.$site_name.o -e $logs_dir/baylor.annotate.$site_name.e -v config=$config,cross_impute_ready_vcf=$cross_impute_ready_vcf,annotate_vcf=$annotate_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$annotate_threads -l walltime=$annotate_walltime -M $pbs_status_mailto -m abe baylor.annotate.single.sh"
  
    if [ $DEBUG -eq 1 ]; then
      echo $annotate_cmd
    else 
      annotate_job_id=`eval $annotate_cmd`
      echo "Baylor: site: $site_name, annotate_job_id: $annotate_job_id"
      echo ${annotate_cmd} > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.qsub
      cat baylor.annotate.single.sh > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.sh
      cat $config > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.config
    
      qalter -o $logs_dir/baylor.annotate.$site_name.$annotate_job_id.o $annotate_job_id
      qalter -e $logs_dir/baylor.annotate.$site_name.$annotate_job_id.e $annotate_job_id
    fi
  else
    echo "$annotate_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi

else
  echo "No males in cohort:$cohort";
fi

## X_nonPAR
site="-L X -XL "$x_par1" -XL "$x_par2
site_name="X_nonPAR"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  annotate_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"
  
  annotate_vcf=$annotate_dir/$cohort.$site_name."annotate.vcf.gz"
  annotate_tbi=$annotate_dir/$cohort.$site_name."annotate.vcf.gz.tbi"

  if [ ! -f $annotate_tbi ]; then
    annotate_cmd="qsub -N baylor.an.$site_name -o $logs_dir/baylor.annotate.$site_name.o -e $logs_dir/baylor.annotate.$site_name.e -v config=$config,cross_impute_ready_vcf=$cross_impute_ready_vcf,annotate_vcf=$annotate_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$annotate_threads -l walltime=$annotate_walltime -M $pbs_status_mailto -m abe baylor.annotate.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $annotate_cmd
    else 
      annotate_job_id=`eval $annotate_cmd`
      echo "Baylor: site: $site_name, annotate_job_id: $annotate_job_id"
      echo ${annotate_cmd} > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.qsub
      cat baylor.annotate.single.sh > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.sh
      cat $config > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.config
    
      qalter -o $logs_dir/baylor.annotate.$site_name.$annotate_job_id.o $annotate_job_id
      qalter -e $logs_dir/baylor.annotate.$site_name.$annotate_job_id.e $annotate_job_id
    fi
  else
    echo "$annotate_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## Y_PAR1
site="-L "$y_par1
site_name="Y_PAR1"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  annotate_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"
  
  annotate_vcf=$annotate_dir/$cohort.$site_name."annotate.vcf.gz"
  annotate_tbi=$annotate_dir/$cohort.$site_name."annotate.vcf.gz.tbi"

  if [ ! -f $annotate_tbi ]; then
    annotate_cmd="qsub -N baylor.an.$site_name -o $logs_dir/baylor.annotate.$site_name.o -e $logs_dir/baylor.annotate.$site_name.e -v config=$config,cross_impute_ready_vcf=$cross_impute_ready_vcf,annotate_vcf=$annotate_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$annotate_threads -l walltime=$annotate_walltime -M $pbs_status_mailto -m abe baylor.annotate.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $annotate_cmd
    else 
      annotate_job_id=`eval $annotate_cmd`
      echo "Baylor: site: $site_name, annotate_job_id: $annotate_job_id"
      echo ${annotate_cmd} > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.qsub
      cat baylor.annotate.single.sh > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.sh
      cat $config > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.config
    
      qalter -o $logs_dir/baylor.annotate.$site_name.$annotate_job_id.o $annotate_job_id
      qalter -e $logs_dir/baylor.annotate.$site_name.$annotate_job_id.e $annotate_job_id
    fi
  else
    echo "$annotate_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi

else
  echo "No males in cohort:$cohort";
fi

## Y_PAR2
site="-L "$y_par2
site_name="Y_PAR2"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  annotate_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"
  
  annotate_vcf=$annotate_dir/$cohort.$site_name."annotate.vcf.gz"
  annotate_tbi=$annotate_dir/$cohort.$site_name."annotate.vcf.gz.tbi"

  if [ ! -f $annotate_tbi ]; then
    annotate_cmd="qsub -N baylor.an.$site_name -o $logs_dir/baylor.annotate.$site_name.o -e $logs_dir/baylor.annotate.$site_name.e -v config=$config,cross_impute_ready_vcf=$cross_impute_ready_vcf,annotate_vcf=$annotate_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$annotate_threads -l walltime=$annotate_walltime -M $pbs_status_mailto -m abe baylor.annotate.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $annotate_cmd
    else 
      annotate_job_id=`eval $annotate_cmd`
      echo "Baylor: site: $site_name, annotate_job_id: $annotate_job_id"
      echo ${annotate_cmd} > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.qsub
      cat baylor.annotate.single.sh > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.sh
      cat $config > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.config
    
      qalter -o $logs_dir/baylor.annotate.$site_name.$annotate_job_id.o $annotate_job_id
      qalter -e $logs_dir/baylor.annotate.$site_name.$annotate_job_id.e $annotate_job_id
    fi
  else
    echo "$annotate_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## Y_nonPAR
site="-L Y -XL "$y_par1" -XL "$y_par2
site_name="Y_nonPAR"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then

  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  annotate_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"
  
  annotate_vcf=$annotate_dir/$cohort.$site_name."annotate.vcf.gz"
  annotate_tbi=$annotate_dir/$cohort.$site_name."annotate.vcf.gz.tbi"

  if [ ! -f $annotate_tbi ]; then
    annotate_cmd="qsub -N baylor.an.$site_name -o $logs_dir/baylor.annotate.$site_name.o -e $logs_dir/baylor.annotate.$site_name.e -v config=$config,cross_impute_ready_vcf=$cross_impute_ready_vcf,annotate_vcf=$annotate_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$annotate_threads -l walltime=$annotate_walltime -M $pbs_status_mailto -m abe baylor.annotate.single.sh"

    if [ $DEBUG -eq 1 ]; then
      echo $annotate_cmd
    else 
      annotate_job_id=`eval $annotate_cmd`
      echo "Baylor: site: $site_name, annotate_job_id: $annotate_job_id"
      echo ${annotate_cmd} > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.qsub
      cat baylor.annotate.single.sh > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.sh
      cat $config > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.config
    
      qalter -o $logs_dir/baylor.annotate.$site_name.$annotate_job_id.o $annotate_job_id
      qalter -e $logs_dir/baylor.annotate.$site_name.$annotate_job_id.e $annotate_job_id
    fi
  else
    echo "$annotate_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

# Females
## X
site="-L X"
site_name="X"

if [ -f $genotype_gvcfs_dir/$cohort.$site_name".vcf.gz" ]; then
  cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
  annotate_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"
  
  annotate_vcf=$annotate_dir/$cohort.$site_name."annotate.vcf.gz"
  annotate_tbi=$annotate_dir/$cohort.$site_name."annotate.vcf.gz.tbi"

  if [ ! -f $annotate_tbi ]; then
    annotate_cmd="qsub -N baylor.an.$site_name -o $logs_dir/baylor.annotate.$site_name.o -e $logs_dir/baylor.annotate.$site_name.e -v config=$config,cross_impute_ready_vcf=$cross_impute_ready_vcf,annotate_vcf=$annotate_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$annotate_threads -l walltime=$annotate_walltime -M $pbs_status_mailto -m abe baylor.annotate.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $annotate_cmd
    else 
      annotate_job_id=`eval $annotate_cmd`
      echo "Baylor: site: $site_name, annotate_job_id: $annotate_job_id"
      echo ${annotate_cmd} > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.qsub
      cat baylor.annotate.single.sh > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.sh
      cat $config > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.config
    
      qalter -o $logs_dir/baylor.annotate.$site_name.$annotate_job_id.o $annotate_job_id
      qalter -e $logs_dir/baylor.annotate.$site_name.$annotate_job_id.e $annotate_job_id
    fi
  else
    echo "$annotate_vcf for cohort:$cohort, site:$site_name has already been created" 
  fi

else
  echo "No females in cohort:$cohort";
fi

# M
site="-L MT"
site_name="MT"

cross_impute_ready_vcf=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz"
annotate_tbi=$cross_impute_ready_dir/$cohort.$site_name."vqsr.cross_impute_ready.vcf.gz.tbi"
  
annotate_vcf=$annotate_dir/$cohort.$site_name."annotate.vcf.gz"
annotate_tbi=$annotate_dir/$cohort.$site_name."annotate.vcf.gz.tbi"

  if [ ! -f $annotate_tbi ]; then
    annotate_cmd="qsub -N baylor.an.$site_name -o $logs_dir/baylor.annotate.$site_name.o -e $logs_dir/baylor.annotate.$site_name.e -v config=$config,cross_impute_ready_vcf=$cross_impute_ready_vcf,annotate_vcf=$annotate_vcf,site=\"$site\" -q $queue -l nodes=1:ppn=$annotate_threads -l walltime=$annotate_walltime -M $pbs_status_mailto -m abe baylor.annotate.single.sh"

   if [ $DEBUG -eq 1 ]; then
    echo $annotate_cmd
  else 
    annotate_job_id=`eval $annotate_cmd`
    echo "Baylor: site: $site_name, annotate_job_id: $annotate_job_id"
    echo ${annotate_cmd} > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.qsub
    cat baylor.annotate.single.sh > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.sh
    cat $config > $logs_dir/baylor.annotate.$site_name.$annotate_job_id.config
    
    qalter -o $logs_dir/baylor.annotate.$site_name.$annotate_job_id.o $annotate_job_id
    qalter -e $logs_dir/baylor.annotate.$site_name.$annotate_job_id.e $annotate_job_id
  fi
else
  echo "$annotate_vcf for cohort:$cohort, site:$site_name has already been created" 
fi
