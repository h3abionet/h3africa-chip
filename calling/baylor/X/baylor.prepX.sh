#!/bin/bash

# First sort out pre VQSR VCFs
if [ ] 
then
  ln -s /shuffle/projects/chipdesign/variant_calling/baylor/genotype_gvcfs_with_basic_annotation/baylor.X_PAR1.basic_annotation.vcf.gz* /shuffle/projects/chipdesign/variant_calling/baylor/X/
  ln -s /shuffle/projects/chipdesign/variant_calling/baylor/genotype_gvcfs_with_basic_annotation/baylor.X.basic_annotation.vcf.gz* /shuffle/projects/chipdesign/variant_calling/baylor/X/

  /opt/exp_soft/bcftools/bcftools merge -m none /shuffle/projects/chipdesign/variant_calling/baylor/X/baylor.X_PAR1.basic_annotation.vcf.gz /shuffle/projects/chipdesign/variant_calling/baylor/X/baylor.X.basic_annotation.vcf.gz -O z -o /shuffle/projects/chipdesign/variant_calling/baylor/X/baylor.X.male.female.basic_annotation.vcf.gz

  /opt/exp_soft/tabix-0.2.6/tabix /shuffle/projects/chipdesign/variant_calling/baylor/X/baylor.X.male.female.basic_annotation.vcf.gz
fi

# Then sort out post VQSR VCFs
ln -s /shuffle/projects/chipdesign/variant_calling/baylor/cross_impute_ready/baylor.X_PAR1.vqsr.cross_impute_ready.basic_annotation.vcf.gz* /shuffle/projects/chipdesign/variant_calling/baylor/X/
ln -s /shuffle/projects/chipdesign/variant_calling/baylor/cross_impute_ready/baylor.X.vqsr.cross_impute_ready.basic_annotation.vcf.gz* /shuffle/projects/chipdesign/variant_calling/baylor/X/

/opt/exp_soft/bcftools/bcftools merge -m none /shuffle/projects/chipdesign/variant_calling/baylor/X/baylor.X_PAR1.vqsr.cross_impute_ready.basic_annotation.vcf.gz /shuffle/projects/chipdesign/variant_calling/baylor/X/baylor.X.vqsr.cross_impute_ready.basic_annotation.vcf.gz -O z -o /shuffle/projects/chipdesign/variant_calling/baylor/X/baylor.X.male.female.vqsr.cross_impute_ready.basic_annotation.vcf.gz

/opt/exp_soft/tabix-0.2.6/tabix /shuffle/projects/chipdesign/variant_calling/baylor/X/baylor.X.male.female.vqsr.cross_impute_ready.basic_annotation.vcf.gz
