#!/bin/bash
DEBUG=0

queue=batch
config=/home/gerrit/projects/chipdesign/variant_calling/trypanogen/dm/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

tmp_dir=$tmp_dir

# The genotype_gvcfs_ready_dir directory must contain a sample/(combined gvcf) folder and the per site vcfs in there
# For example
# /shuffle/projects/chipdesign/variant_calling/trypanogen/dm/1-Bolk_006-2_150310_L006
# 1-Bolk_006-2_150310_L006.1.g.vcf.gz
# .
# ..
# ...
# 1-Bolk_006-2_150310_L006.22.g.vcf.gz
genotype_gvcfs_ready_dir=$genotype_gvcfs_ready_dir
genotype_gvcfs_dir=$genotype_gvcfs_dir
cohort=$cohort
logs_dir=$logs_dir"/genotype_gvcfs."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

gatk_genotype_gvcfs_threads=$(( $gatk_genotype_gvcfs_data_threads*$gatk_genotype_gvcfs_cpu_threads_per_data_thread ))

# GenotypeGVCFs the autosomes
for i in {1..22}; do 
  site="-L "$i
  site_name=$i
  ls -1 $genotype_gvcfs_ready_dir/*/*.$site_name.g.vcf.gz > $tmp_dir/$cohort.$site_name.g.vcf.gz.list
  gvcf_list=$tmp_dir/$cohort.$site_name.g.vcf.gz.list
  vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"
  tbi=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz.tbi"
  
  if [ ! -f $tbi ]; then
    genotype_gvcfs_cmd="qsub -N trypanogen.gtg.$site_name -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.o -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.e -v config=$config,gvcf_list=$gvcf_list,site=\"$site\",vcf=$vcf -q $queue -l nodes=1:ppn=$gatk_genotype_gvcfs_threads -l walltime=$gatk_genotype_gvcfs_walltime -M $pbs_status_mailto -m abe trypanogen.genotype_gvcfs.single.sh"
 
    if [ $DEBUG -eq 1 ]; then
      echo $genotype_gvcfs_cmd
    else 
      genotype_gvcfs_job_id=`eval $genotype_gvcfs_cmd`
      echo "TrypanoGEN: site: $site_name, genotype_gvcfs_job_id: $genotype_gvcfs_job_id"
      echo ${genotype_gvcfs_cmd} > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.qsub
      cat trypanogen.genotype_gvcfs.single.sh > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.sh
      cat $config > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.config
    
      qalter -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.o $genotype_gvcfs_job_id
      qalter -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.e $genotype_gvcfs_job_id
    fi
  else
    echo "$vcf for cohort:$cohort, site:$site_name has already been created" 
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

if `ls -1 $genotype_gvcfs_ready_dir/*/*.$site_name.g.vcf.gz > $tmp_dir/$cohort.$site_name.g.vcf.gz.list 2>/dev/null`; then
  gvcf_list=$tmp_dir/$cohort.$site_name.g.vcf.gz.list
  vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"
  tbi=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz.tbi"

   if [ ! -f $tbi ]; then
    genotype_gvcfs_cmd="qsub -N trypanogen.gtg.$site_name -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.o -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.e -v config=$config,gvcf_list=$gvcf_list,site=\"$site\",vcf=$vcf -q $queue -l nodes=1:ppn=$gatk_genotype_gvcfs_threads -l walltime=$gatk_genotype_gvcfs_walltime -M $pbs_status_mailto -m abe trypanogen.genotype_gvcfs.single.sh"

     if [ $DEBUG -eq 1 ]; then
       echo $genotype_gvcfs_cmd
     else    
       genotype_gvcfs_job_id=`eval $genotype_gvcfs_cmd`
       echo "TrypanoGEN: site: $site_name, genotype_gvcfs_job_id: $genotype_gvcfs_job_id"
       echo ${genotype_gvcfs_cmd} > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.qsub
       cat trypanogen.genotype_gvcfs.single.sh > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.sh
       cat $config > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.config

       qalter -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.o $genotype_gvcfs_job_id
       qalter -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.e $genotype_gvcfs_job_id
     fi
  else
    echo "$vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## X_PAR2
site="-L "$x_par2
site_name="X_PAR2"

if `ls -1 $genotype_gvcfs_ready_dir/*/*.$site_name.g.vcf.gz > $tmp_dir/$cohort.$site_name.g.vcf.gz.list 2>/dev/null`; then
  gvcf_list=$tmp_dir/$cohort.$site_name.g.vcf.gz.list
  vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"
  tbi=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz.tbi"

   if [ ! -f $tbi ]; then
    genotype_gvcfs_cmd="qsub -N trypanogen.gtg.$site_name -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.o -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.e -v config=$config,gvcf_list=$gvcf_list,site=\"$site\",vcf=$vcf -q $queue -l nodes=1:ppn=$gatk_genotype_gvcfs_threads -l walltime=$gatk_genotype_gvcfs_walltime -M $pbs_status_mailto -m abe trypanogen.genotype_gvcfs.single.sh"

     if [ $DEBUG -eq 1 ]; then
       echo $genotype_gvcfs_cmd
     else    
       genotype_gvcfs_job_id=`eval $genotype_gvcfs_cmd`
       echo "TrypanoGEN: site: $site_name, genotype_gvcfs_job_id: $genotype_gvcfs_job_id"
       echo ${genotype_gvcfs_cmd} > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.qsub
       cat trypanogen.genotype_gvcfs.single.sh > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.sh
       cat $config > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.config

       qalter -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.o $genotype_gvcfs_job_id
       qalter -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.e $genotype_gvcfs_job_id
     fi
  else
    echo "$vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## X_nonPAR
site="-L X -XL "$x_par1" -XL "$x_par2
site_name="X_nonPAR"

if `ls -1 $genotype_gvcfs_ready_dir/*/*.$site_name.g.vcf.gz > $tmp_dir/$cohort.$site_name.g.vcf.gz.list 2>/dev/null`; then
  gvcf_list=$tmp_dir/$cohort.$site_name.g.vcf.gz.list
  vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"
  tbi=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz.tbi"

   if [ ! -f $tbi ]; then
    genotype_gvcfs_cmd="qsub -N trypanogen.gtg.$site_name -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.o -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.e -v config=$config,gvcf_list=$gvcf_list,site=\"$site\",vcf=$vcf -q $queue -l nodes=1:ppn=$gatk_genotype_gvcfs_threads -l walltime=$gatk_genotype_gvcfs_walltime -M $pbs_status_mailto -m abe trypanogen.genotype_gvcfs.single.sh"

     if [ $DEBUG -eq 1 ]; then
       echo $genotype_gvcfs_cmd
     else
       genotype_gvcfs_job_id=`eval $genotype_gvcfs_cmd`
       echo "TrypanoGEN: site: $site_name, genotype_gvcfs_job_id: $genotype_gvcfs_job_id"
       echo ${genotype_gvcfs_cmd} > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.qsub
       cat trypanogen.genotype_gvcfs.single.sh > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.sh
       cat $config > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.config

       qalter -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.o $genotype_gvcfs_job_id
       qalter -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.e $genotype_gvcfs_job_id
     fi
  else
    echo "$vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## Y_PAR1
site="-L "$y_par1
site_name="Y_PAR1"

if `ls -1 $genotype_gvcfs_ready_dir/*/*.$site_name.g.vcf.gz > $tmp_dir/$cohort.$site_name.g.vcf.gz.list 2>/dev/null`; then
  gvcf_list=$tmp_dir/$cohort.$site_name.g.vcf.gz.list
  vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"
  tbi=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz.tbi"

   if [ ! -f $tbi ]; then
    genotype_gvcfs_cmd="qsub -N trypanogen.gtg.$site_name -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.o -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.e -v config=$config,gvcf_list=$gvcf_list,site=\"$site\",vcf=$vcf -q $queue -l nodes=1:ppn=$gatk_genotype_gvcfs_threads -l walltime=$gatk_genotype_gvcfs_walltime -M $pbs_status_mailto -m abe trypanogen.genotype_gvcfs.single.sh"

     if [ $DEBUG -eq 1 ]; then
       echo $genotype_gvcfs_cmd
     else
       genotype_gvcfs_job_id=`eval $genotype_gvcfs_cmd`
       echo "TrypanoGEN: site: $site_name, genotype_gvcfs_job_id: $genotype_gvcfs_job_id"
       echo ${genotype_gvcfs_cmd} > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.qsub
       cat trypanogen.genotype_gvcfs.single.sh > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.sh
       cat $config > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.config

       qalter -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.o $genotype_gvcfs_job_id
       qalter -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.e $genotype_gvcfs_job_id
     fi
  else
    echo "$vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## Y_PAR2
site="-L "$y_par2
site_name="Y_PAR2"

if `ls -1 $genotype_gvcfs_ready_dir/*/*.$site_name.g.vcf.gz > $tmp_dir/$cohort.$site_name.g.vcf.gz.list 2>/dev/null`; then
  gvcf_list=$tmp_dir/$cohort.$site_name.g.vcf.gz.list
  vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"
  tbi=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz.tbi"

   if [ ! -f $tbi ]; then
    genotype_gvcfs_cmd="qsub -N trypanogen.gtg.$site_name -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.o -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.e -v config=$config,gvcf_list=$gvcf_list,site=\"$site\",vcf=$vcf -q $queue -l nodes=1:ppn=$gatk_genotype_gvcfs_threads -l walltime=$gatk_genotype_gvcfs_walltime -M $pbs_status_mailto -m abe trypanogen.genotype_gvcfs.single.sh"

     if [ $DEBUG -eq 1 ]; then
       echo $genotype_gvcfs_cmd
     else
       genotype_gvcfs_job_id=`eval $genotype_gvcfs_cmd`
       echo "TrypanoGEN: site: $site_name, genotype_gvcfs_job_id: $genotype_gvcfs_job_id"
       echo ${genotype_gvcfs_cmd} > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.qsub
       cat trypanogen.genotype_gvcfs.single.sh > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.sh
       cat $config > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.config

       qalter -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.o $genotype_gvcfs_job_id
       qalter -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.e $genotype_gvcfs_job_id
     fi
  else
    echo "$vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

## Y_nonPAR
site="-L Y -XL "$y_par1" -XL "$y_par2
site_name="Y_nonPAR"

if `ls -1 $genotype_gvcfs_ready_dir/*/*.$site_name.g.vcf.gz > $tmp_dir/$cohort.$site_name.g.vcf.gz.list 2>/dev/null`; then
  gvcf_list=$tmp_dir/$cohort.$site_name.g.vcf.gz.list
  vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"
  tbi=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz.tbi"

   if [ ! -f $tbi ]; then
    genotype_gvcfs_cmd="qsub -N trypanogen.gtg.$site_name -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.o -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.e -v config=$config,gvcf_list=$gvcf_list,site=\"$site\",vcf=$vcf -q $queue -l nodes=1:ppn=$gatk_genotype_gvcfs_threads -l walltime=$gatk_genotype_gvcfs_walltime -M $pbs_status_mailto -m abe trypanogen.genotype_gvcfs.single.sh"

     if [ $DEBUG -eq 1 ]; then
       echo $genotype_gvcfs_cmd
     else
       genotype_gvcfs_job_id=`eval $genotype_gvcfs_cmd`
       echo "TrypanoGEN: site: $site_name, genotype_gvcfs_job_id: $genotype_gvcfs_job_id"
       echo ${genotype_gvcfs_cmd} > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.qsub
       cat trypanogen.genotype_gvcfs.single.sh > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.sh
       cat $config > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.config

       qalter -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.o $genotype_gvcfs_job_id
       qalter -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.e $genotype_gvcfs_job_id
     fi
  else
    echo "$vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No males in cohort:$cohort";
fi

# Females
## X
site="-L X"
site_name="X"

if `ls -1 $genotype_gvcfs_ready_dir/*/*.$site_name.g.vcf.gz > $tmp_dir/$cohort.$site_name.g.vcf.gz.list 2>/dev/null`; then
  gvcf_list=$tmp_dir/$cohort.$site_name.g.vcf.gz.list
  vcf=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz"
  tbi=$genotype_gvcfs_dir/$cohort.$site_name".vcf.gz.tbi"

   if [ ! -f $tbi ]; then
    genotype_gvcfs_cmd="qsub -N trypanogen.gtg.$site_name -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.o -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.e -v config=$config,gvcf_list=$gvcf_list,site=\"$site\",vcf=$vcf -q $queue -l nodes=1:ppn=$gatk_genotype_gvcfs_threads -l walltime=$gatk_genotype_gvcfs_walltime -M $pbs_status_mailto -m abe trypanogen.genotype_gvcfs.single.sh"

     if [ $DEBUG -eq 1 ]; then
       echo $genotype_gvcfs_cmd
     else
       genotype_gvcfs_job_id=`eval $genotype_gvcfs_cmd`
       echo "TrypanoGEN: site: $site_name, genotype_gvcfs_job_id: $genotype_gvcfs_job_id"
       echo ${genotype_gvcfs_cmd} > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.qsub
       cat trypanogen.genotype_gvcfs.single.sh > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.sh
       cat $config > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.config

       qalter -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.o $genotype_gvcfs_job_id
       qalter -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.e $genotype_gvcfs_job_id
     fi
  else
    echo "$vcf for cohort:$cohort, site:$site_name has already been created" 
  fi
else
  echo "No females in cohort:$cohort";
fi



# M
site="-L MT"
site_name="M"
ls -1 $genotype_gvcfs_ready_dir/*/*.$site_name.g.vcf.gz > $tmp_dir/$cohort.$site_name.g.vcf.gz.list
gvcf_list=$tmp_dir/$cohort.$site_name.g.vcf.gz.list
vcf=$genotype_gvcfs_dir/$cohort.$site_name"T.vcf.gz"
tbi=$genotype_gvcfs_dir/$cohort.$site_name"T.vcf.gz.tbi"

if [ ! -f $tbi ]; then
  genotype_gvcfs_cmd="qsub -N trypanogen.gtg.$site_name -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.o -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.e -v config=$config,gvcf_list=$gvcf_list,site=\"$site\",vcf=$vcf -q $queue -l nodes=1:ppn=$gatk_genotype_gvcfs_threads -l walltime=$gatk_genotype_gvcfs_walltime -M $pbs_status_mailto -m abe trypanogen.genotype_gvcfs.single.sh"

  if [ $DEBUG -eq 1 ]; then
    echo $genotype_gvcfs_cmd
  else
    genotype_gvcfs_job_id=`eval $genotype_gvcfs_cmd`
    echo "TrypanoGEN: site: $site_name, genotype_gvcfs_job_id: $genotype_gvcfs_job_id"
    echo ${genotype_gvcfs_cmd} > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.qsub
    cat trypanogen.genotype_gvcfs.single.sh > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.sh
    cat $config > $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.config

    qalter -o $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.o $genotype_gvcfs_job_id
    qalter -e $logs_dir/trypanogen.genotype_gvcfs.$site_name.$genotype_gvcfs_job_id.e $genotype_gvcfs_job_id
 fi
else
  echo "$vcf for cohort:$cohort, site:$site_name has already been created" 
fi

