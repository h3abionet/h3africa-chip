#/bin/bash
DEBUG=0

queue=H3A
config=/export/home/gbotha/projects/h3abionet/chipdesign/variant_calling/baylor/dm/config.txt

# For settings we need to get the mem, cpu, and queue settings
. $config

logs_dir_root=$logs_dir"/hc_dm."`date +"%y%m%d%H%M%S"`
mkdir $logs_dir_root

dm_dir=$dm_dir

hc_sites_list=$hc_sites_list
gender_list=$gender_list
verifybamid_passed_list=$verifybamid_passed_list

gatk_hc_threads=$(( $gatk_hc_data_threads*$gatk_hc_cpu_threads_per_data_thread ))

function check_list () { 
for i in $1; do 
  if [ $i == $2 ]; then 
    echo "1";
    return 1;
  fi; 
done; 
echo ""; 
return 0
}

bam_passed_list="";
while read bam; do 
  file_name=$(basename $bam);
  id=${file_name%.bwa*};
  bam_passed_list=$bam_passed_list$id" "; 
done < $verifybamid_passed_list

sample_count=1

while read gender_entry; do
  
  # Need to check if the sample is in the verfieBamID pass list
  sample_id=`echo -e "$gender_entry" | awk -F$'\t' '{print $1}'`;
  found=$(check_list "$bam_passed_list" $sample_id)  

  if [ $found ]; then
    echo "Sample $sample_id did pass verifyBamID. Downstream processing will be done.";

    # Get bam path from list
    bam=`grep -P "$sample_id" $verifybamid_passed_list`

    sample_dir=$dm_dir"/"$sample_id
    logs_dir=$logs_dir_root"/"$sample_id

    if [ ! -d $sample_dir ]; then
      mkdir $sample_dir
    fi

    # Will have a per sample log directory 
    if [ ! -d $logs_dir ]; then
      mkdir $logs_dir
    fi

####################
    # Call the autosomes
    for i in {1..22}; do 
      ploidy=2
      site=`grep -P "^$i\t" $hc_sites_list | awk -F'\t' '{print $2":"$3"-"$4}'`; 
      site="-L "$site
      site_name=$i
      vcf=$sample_dir/$sample_id.$site_name".g.vcf.gz"
      tbi=$sample_dir/$sample_id.$site_name".g.vcf.gz.tbi"

      # First check if the vcf index has been created has been created before. If it has been created we can skip that site.
      if [ ! -f $tbi ]; then
         pstracker_log_path=$logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name  
         hc_dm_cmd="qsub -N blr.hcd.$sample_count.$site_name -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.o -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.e -v config=$config,bam=$bam,site=\"$site\",ploidy=$ploidy,vcf=$vcf,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_hc_threads:mem=${gatk_hc_mem}B -l walltime=$gatk_hc_walltime -M $pbs_status_mailto -m abe baylor.hc.dm.single.sh"
 
        if [ $DEBUG -eq 1 ]; then
          echo $hc_dm_cmd
        else 
          hc_dm_job_id=`eval $hc_dm_cmd`
          echo "Baylor: $sample_id, site: $site_name, hc_dm_job_id: $hc_dm_job_id"
          echo ${hc_dm_cmd} > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.qsub
          cat baylor.hc.dm.single.sh > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.sh
          cat $config > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.config
    
          qalter -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.o $hc_dm_job_id
          qalter -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.e $hc_dm_job_id
        fi
      else
        echo "$vcf for $sample_id has already been created" 
      fi
    done; 
####################
  
    # For males
    ## First the X chromosome
####################
    ### Run diploid  on X_PAR1
    site=`echo -e "$gender_entry" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^X_PAR1\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
    if [ $site ]; then
      ploidy=2
      site="-L "$site
      site_name="X_PAR1"
      vcf=$sample_dir/$sample_id.$site_name".g.vcf.gz"
      tbi=$sample_dir/$sample_id.$site_name".g.vcf.gz.tbi"
      
      # First check if the vcf index has been created has been created before. If it has been created we can skip that site.
      if [ ! -f $tbi ]; then
        pstracker_log_path=$logs_dir/baylor.hc_dm.$sample_id.$sample_count.$sample_id.$site_name 
        hc_dm_cmd="qsub -N blr.hcd.$sample_count.X1 -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.o -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.e -v config=$config,bam=$bam,site=\"$site\",ploidy=$ploidy,vcf=$vcf,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_hc_threads:mem=${gatk_hc_mem}B -l walltime=$gatk_hc_walltime -M $pbs_status_mailto -m abe baylor.hc.dm.single.sh"
 
        if [ $DEBUG -eq 1 ]; then
          echo $hc_dm_cmd
        else 
          hc_dm_job_id=`eval $hc_dm_cmd`
          echo "Baylor: $sample_id, site: $site_name, hc_dm_job_id: $hc_dm_job_id"
          echo ${hc_dm_cmd} > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.qsub
          cat baylor.hc.dm.single.sh > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.sh
          cat $config > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.config
    
          qalter -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.o $hc_dm_job_id
          qalter -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.e $hc_dm_job_id
        fi
      else
    	echo "$vcf for $sample_id has already been created" 
      fi
####################

####################
      ### Run diploid  on X_PAR2
      site=`echo -e "$gender_entry" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^X_PAR2\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site="-L "$site
      site_name="X_PAR2"
      vcf=$sample_dir/$sample_id.$site_name".g.vcf.gz"
      tbi=$sample_dir/$sample_id.$site_name".g.vcf.gz.tbi"
      
      # First check if the vcf index has been created has been created before. If it has been created we can skip that site.
      if [ ! -f $tbi ]; then
        pstracker_log_path=$logs_dir/baylor.hc_dm.$sample_id.$sample_count.$sample_id.$site_name 
        hc_dm_cmd="qsub -N blr.hcd.$sample_count.X2 -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.o -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.e -v config=$config,bam=$bam,site=\"$site\",ploidy=$ploidy,vcf=$vcf,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_hc_threads:mem=${gatk_hc_mem}B -l walltime=$gatk_hc_walltime -M $pbs_status_mailto -m abe baylor.hc.dm.single.sh"
 
        if [ $DEBUG -eq 1 ]; then
          echo $hc_dm_cmd
        else 
          hc_dm_job_id=`eval $hc_dm_cmd`
          echo "Baylor: $sample_id, site: $site_name, hc_dm_job_id: $hc_dm_job_id"
          echo ${hc_dm_cmd} > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.qsub
          cat baylor.hc.dm.single.sh > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.sh
          cat $config > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.config
    
          qalter -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.o $hc_dm_job_id
          qalter -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.e $hc_dm_job_id
        fi
      else
    	echo "$vcf for $sample_id has already been created" 
      fi
####################

####################
      ### Run haploid  on X_nonPAR
      ploidy=1
      site="-L "$site
      site_1=`echo -e "$gender_entry" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^X_PAR1\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site_2=`echo -e "$gender_entry" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^X_PAR2\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site="-L X -XL "$site_1" -XL "$site_2
      site_name="X_nonPAR"
      vcf=$sample_dir/$sample_id.$site_name".g.vcf.gz"
      tbi=$sample_dir/$sample_id.$site_name".g.vcf.gz.tbi"
      
      # First check if the vcf index has been created has been created before. If it has been created we can skip that site.
      if [ ! -f $tbi ]; then
        pstracker_log_path=$logs_dir/baylor.hc_dm.$sample_id.$sample_count.$sample_id.$site_name 
        hc_dm_cmd="qsub -N blr.hcd.$sample_count.Xn -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.o -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.e -v config=$config,bam=$bam,site=\"$site\",ploidy=$ploidy,vcf=$vcf,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_hc_threads:mem=${gatk_hc_mem}B -l walltime=$gatk_hc_walltime -M $pbs_status_mailto -m abe baylor.hc.dm.single.sh"
 
        if [ $DEBUG -eq 1 ]; then
          echo $hc_dm_cmd
        else 
          hc_dm_job_id=`eval $hc_dm_cmd`
          echo "Baylor: $sample_id, site: $site_name, hc_dm_job_id: $hc_dm_job_id"
          echo ${hc_dm_cmd} > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.qsub
          cat baylor.hc.dm.single.sh > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.sh
          cat $config > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.config
    
          qalter -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.o $hc_dm_job_id
          qalter -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.e $hc_dm_job_id
        fi
      else
    	echo "$vcf for $sample_id has already been created" 
      fi
####################
    
####################
      ## Then the Y chromosome
      ### Run diploid  on Y_PAR1
      ploidy=2
      site=`echo -e "$gender_entry" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^Y_PAR1\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site="-L "$site
      site_name="Y_PAR1"
      vcf=$sample_dir/$sample_id.$site_name".g.vcf.gz"
      tbi=$sample_dir/$sample_id.$site_name".g.vcf.gz.tbi"
      
      # First check if the vcf index has been created has been created before. If it has been created we can skip that site.
      if [ ! -f $tbi ]; then
        pstracker_log_path=$logs_dir/baylor.hc_dm.$sample_id.$sample_count.$sample_id.$site_name 
        hc_dm_cmd="qsub -N blr.hcd.$sample_count.Y1 -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.o -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.e -v config=$config,bam=$bam,site=\"$site\",ploidy=$ploidy,vcf=$vcf,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_hc_threads:mem=${gatk_hc_mem}B -l walltime=$gatk_hc_walltime -M $pbs_status_mailto -m abe baylor.hc.dm.single.sh"
 
        if [ $DEBUG -eq 1 ]
        then
          echo $hc_dm_cmd
        else 
          hc_dm_job_id=`eval $hc_dm_cmd`
          echo "Baylor: $sample_id, site: $site_name, hc_dm_job_id: $hc_dm_job_id"
          echo ${hc_dm_cmd} > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.qsub
          cat baylor.hc.dm.single.sh > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.sh
          cat $config > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.config
    
          qalter -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.o $hc_dm_job_id
          qalter -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.e $hc_dm_job_id
        fi
      else
    	echo "$vcf for $sample_id has already been created" 
      fi
####################

####################
    ### Run diploid  on Y_PAR2
      site=`echo -e "$gender_entry" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^Y_PAR2\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site="-L "$site
      site_name="Y_PAR2"
      vcf=$sample_dir/$sample_id.$site_name".g.vcf.gz"
      tbi=$sample_dir/$sample_id.$site_name".g.vcf.gz.tbi"
      
      # First check if the vcf index has been created has been created before. If it has been created we can skip that site.
      if [ ! -f $tbi ]; then
        pstracker_log_path=$logs_dir/baylor.hc_dm.$sample_id.$sample_count.$sample_id.$site_name 
        hc_dm_cmd="qsub -N blr.hcd.$sample_count.Y2 -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.o -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.e -v config=$config,bam=$bam,site=\"$site\",ploidy=$ploidy,vcf=$vcf,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_hc_threads:mem=${gatk_hc_mem}B -l walltime=$gatk_hc_walltime -M $pbs_status_mailto -m abe baylor.hc.dm.single.sh"
 
        if [ $DEBUG -eq 1 ]; then
          echo $hc_dm_cmd
        else 
          hc_dm_job_id=`eval $hc_dm_cmd`
          echo "Baylor: $sample_id, site: $site_name, hc_dm_job_id: $hc_dm_job_id"
          echo ${hc_dm_cmd} > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.qsub
          cat baylor.hc.dm.single.sh > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.sh
          cat $config > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.config
    
          qalter -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.o $hc_dm_job_id
          qalter -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.e $hc_dm_job_id
        fi
      else
    	echo "$vcf for $sample_id has already been created" 
      fi
####################

####################
      ### Run haploid  on Y_nonPAR
      ploidy=1
      site_1=`echo -e "$gender_entry" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^Y_PAR1\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site_2=`echo -e "$gender_entry" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^Y_PAR2\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site="-L Y -XL "$site_1" -XL "$site_2
      site_name="Y_nonPAR"
      vcf=$sample_dir/$sample_id.$site_name".g.vcf.gz"
      tbi=$sample_dir/$sample_id.$site_name".g.vcf.gz.tbi"
      
      # First check if the vcf index has been created has been created before. If it has been created we can skip that site.
      if [ ! -f $tbi ]; then
        pstracker_log_path=$logs_dir/baylor.hc_dm.$sample_id.$sample_count.$sample_id.$site_name 
        hc_dm_cmd="qsub -N blr.hcd.$sample_count.Yn -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.o -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.e -v config=$config,bam=$bam,site=\"$site\",ploidy=$ploidy,vcf=$vcf,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_hc_threads:mem=${gatk_hc_mem}B -l walltime=$gatk_hc_walltime -M $pbs_status_mailto -m abe baylor.hc.dm.single.sh"
 
        if [ $DEBUG -eq 1 ]; then
          echo $hc_dm_cmd
        else 
          hc_dm_job_id=`eval $hc_dm_cmd`
          echo "Baylor: $sample_id, site: $site_name, hc_dm_job_id: $hc_dm_job_id"
          echo ${hc_dm_cmd} > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.qsub
          cat baylor.hc.dm.single.sh > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.sh
          cat $config > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.config
    
          qalter -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.o $hc_dm_job_id
          qalter -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.e $hc_dm_job_id
        fi
      else
    	echo "$vcf for $sample_id has already been created" 
      fi
    fi
####################
  
####################
    # For females
    ## X chromosome
    ### Run diploid  on X
    site=""
    site=`echo -e "$gender_entry" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="f"){system("grep -P \"^X\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
    if [ $site ]; then
      ploidy=2
      site="-L "$site
      site_name="X"
      vcf=$sample_dir/$sample_id.$site_name".g.vcf.gz"
      tbi=$sample_dir/$sample_id.$site_name".g.vcf.gz.tbi"
      
      # First check if the vcf index has been created has been created before. If it has been created we can skip that site.
      if [ ! -f $tbi ]; then
        pstracker_log_path=$logs_dir/baylor.hc_dm.$sample_id.$sample_count.$sample_id.$site_name 
        hc_dm_cmd="qsub -N blr.hcd.$sample_count.X -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.o -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.e -v config=$config,bam=$bam,site=\"$site\",ploidy=$ploidy,vcf=$vcf,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_hc_threads:mem=${gatk_hc_mem}B -l walltime=$gatk_hc_walltime -M $pbs_status_mailto -m abe baylor.hc.dm.single.sh"
 
        if [ $DEBUG -eq 1 ]; then
          echo $hc_dm_cmd
        else 
          hc_dm_job_id=`eval $hc_dm_cmd`
          echo "Baylor: $sample_id, site: $site_name, hc_dm_job_id: $hc_dm_job_id"
          echo ${hc_dm_cmd} > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.qsub
          cat baylor.hc.dm.single.sh > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.sh
          cat $config > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.config
    
          qalter -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.o $hc_dm_job_id
          qalter -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.e $hc_dm_job_id
        fi
      else
    	echo "$vcf for $sample_id has already been created" 
      fi 
    fi
####################
  
####################
    # Call mitochondria
    site=`grep -P "^MT\t" $hc_sites_list | awk -F'\t' '{print $2":"$3"-"$4}'`;
    ploidy=2
    site="-L "$site
    site_name="M"
    vcf=$sample_dir/$sample_id.$site_name".g.vcf.gz"
    tbi=$sample_dir/$sample_id.$site_name".g.vcf.gz.tbi"
      
    # First check if the vcf index has been created has been created before. If it has been created we can skip that site.
    if [ ! -f $tbi ]; then
      pstracker_log_path=$logs_dir/baylor.hc_dm.$sample_id.$sample_count.$sample_id.$site_name 
      hc_dm_cmd="qsub -N blr.hcd.$sample_count.M -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.o -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.e -v config=$config,bam=$bam,site=\"$site\",ploidy=$ploidy,vcf=$vcf,pstracker_log_path=$pstracker_log_path -q $queue -l select=1:ncpus=$gatk_hc_threads:mem=${gatk_hc_mem}B -l walltime=$gatk_hc_walltime -M $pbs_status_mailto -m abe baylor.hc.dm.single.sh"
 
      if [ $DEBUG -eq 1 ]; then
        echo $hc_dm_cmd
      else 
        hc_dm_job_id=`eval $hc_dm_cmd`
        echo "Baylor: $sample_id, site: $site_name, hc_dm_job_id: $hc_dm_job_id"
        echo ${hc_dm_cmd} > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.qsub
        cat baylor.hc.dm.single.sh > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.sh
        cat $config > $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.config
    
        qalter -o $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.o $hc_dm_job_id
        qalter -e $logs_dir/baylor.hc_dm.$sample_id.$sample_count.$site_name.$hc_dm_job_id.e $hc_dm_job_id
      fi
    else
     echo "$vcf for $sample_id has already been created" 
    fi  
####################
  else
    echo "Sample $sample_id didn't pass verifyBamID. No downstream processing will be done."; 
  fi
 
 (( sample_count+=1 ))

done < $gender_list
