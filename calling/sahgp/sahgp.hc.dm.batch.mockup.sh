#/bin/bash
hc_sites_list=/home/gerrit/workspace/chipdesign/variant_calling/hc_sites.list
gender_list=/home/gerrit/workspace/chipdesign/variant_calling/sahgp/sahgp.gender.list
verifybamid_passed_list=/home/gerrit/workspace/chipdesign/variant_calling/sahgp/sahgp.verifybamid.passed.list

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
while read line; do bam_passed_list=$bam_passed_list$line" "; done < $verifybamid_passed_list

while read line; do
  # Need to check if the sample is in the verfieBamID pass list
  sample_id=`echo -e "$line" | awk -F$'\t' '{print $1}'`;
  found=$(check_list "$bam_passed_list" $sample_id)  
 
  if [ $found ]; then
    echo "Sample $sample_id did pass verifyBamID. Downstream processing will be done.";
 
    # Call the autosomes
    for i in {1..22}; do 
      ploidy=2
      site=`grep -P "^$i\t" $hc_sites_list | awk -F'\t' '{print $2":"$3"-"$4}'`; 
      site="-L "$site
      echo "Call qsub -v site=$site,ploidy=$ploidy .... sahgp.hc.dm.single.sh"
    done; 
  
    # For males
    ## First the X chromosome
    ### Run diploid  on X_PAR1
    site=`echo -e "$line" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^X_PAR1\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
    if [ $site ];
    then
      ploidy=2
      site="-L "$site
      echo "Call qsub -v site=$site,ploidy=$ploidy .... sahgp.hc.dm.single.sh"
      ### Run diploid  on X_PAR2
      site=`echo -e "$line" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^X_PAR2\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site="-L "$site
      echo "Call qsub -v site=$site,ploidy=$ploidy .... sahgp.hc.dm.single.sh"
      ### Run haploid  on X_nonPAR
      ploidy=1
      site="-L "$site
      site_1=`echo -e "$line" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^X_PAR1\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site_2=`echo -e "$line" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^X_PAR2\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site="-XL "$site_1" -XL "$site_2
      echo "Call qsub -v site=$site,ploidy=$ploidy .... sahgp.hc.dm.single.sh"
    
      ## Then the Y chromosome
      ### Run diploid  on Y_PAR1
      ploidy=2
      site=`echo -e "$line" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^Y_PAR1\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site="-L "$site
      echo "Call qsub -v site=$site,ploidy=$ploidy .... sahgp.hc.dm.single.sh"
      ### Run diploid  on Y_PAR2
      site=`echo -e "$line" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^Y_PAR2\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site="-L "$site
      echo "Call qsub -v site=$site,ploidy=$ploidy .... sahgp.hc.dm.single.sh"
      ### Run haploid  on Y_nonPAR
      ploidy=1
      site_1=`echo -e "$line" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^Y_PAR1\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site_2=`echo -e "$line" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="m"){system("grep -P \"^Y_PAR2\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
      site="-XL "$site_1" -XL "$site_2
      echo "Call qsub -v site=$site,ploidy=$ploidy .... sahgp.hc.dm.single.sh"
    fi
  
    # For females
    ## X chromosome
    ### Run diploid  on X
    site=""
    site=`echo -e "$line" | awk -F$'\t' -v hc_sites_list=$hc_sites_list '{if($2=="f"){system("grep -P \"^X\t\" "hc_sites_list)}}' | awk -F'\t' '{print $2":"$3"-"$4}'`;
    if [ $site ];
    then
      ploidy=2
      site="-L "$site
      echo "Call qsub -v site=$site,ploidy=$ploidy .... sahgp.hc.dm.single.sh"
    fi
  
    # Call mitochondria
    site=`grep -P "^MT\t" $hc_sites_list | awk -F'\t' '{print $2":"$3"-"$4}'`;
    ploidy=2
    site="-L "$site
    echo "Call qsub -v site=$site,ploidy=$ploidy .... sahgp.hc.dm.single.sh"
  else
    echo "Sample $sample_id didn't pass verifyBamID. No downstream processing will be done."; 
  fi

done < $gender_list
