#/bin/bash

DEBUG=0

chr=$1

cbio_sites="/shuffle/projects/chipdesign/variant_calling/phasing_ready_redo/$chr.post-vqsr.sites.vcf.gz"
in="/shuffle/projects/chipdesign/variant_calling/h3a/clean_vcfs/h3a.$chr.cleaned.vcf.gz"
out="/shuffle/projects/chipdesign/variant_calling/h3a/clean_vcfs_non_sanger/h3a.non_sanger.cleaned.$chr.vcf.gz"

echo $cbio_sites
echo $in
echo $out

# Now combine the two sets
cmd="/opt/exp_soft/bcftools/bcftools view -R $cbio_sites -o $out -O z $in"
echo $cmd
if [ $DEBUG -eq 0 ]; then eval $cmd; fi

cmd="/opt/exp_soft/tabix-0.2.6/tabix -p vcf $out"
echo $cmd
if [ $DEBUG -eq 0 ]; then eval $cmd; fi

