#!/bin/bash

# First sort out pre VQSR VCFs
ln -s /shuffle/projects/chipdesign/variant_calling/trypanogen/genotype_gvcfs_with_basic_annotation/trypanogen.X_PAR1.basic_annotation.vcf.gz* /shuffle/projects/chipdesign/variant_calling/trypanogen/X/
ln -s /shuffle/projects/chipdesign/variant_calling/trypanogen/genotype_gvcfs_with_basic_annotation/trypanogen.X.basic_annotation.vcf.gz* /shuffle/projects/chipdesign/variant_calling/trypanogen/X/

/opt/exp_soft/bcftools/bcftools merge -m none /shuffle/projects/chipdesign/variant_calling/trypanogen/X/trypanogen.X_PAR1.basic_annotation.vcf.gz /shuffle/projects/chipdesign/variant_calling/trypanogen/X/trypanogen.X.basic_annotation.vcf.gz -O z -o /shuffle/projects/chipdesign/variant_calling/trypanogen/X/trypanogen.X.male.female.basic_annotation.vcf.gz

/opt/exp_soft/tabix-0.2.6/tabix /shuffle/projects/chipdesign/variant_calling/trypanogen/X/trypanogen.X.male.female.basic_annotation.vcf.gz

# Then sort out post VQSR VCFs
ln -s /shuffle/projects/chipdesign/variant_calling/trypanogen/cross_impute_ready/trypanogen.X_PAR1.vqsr.cross_impute_ready.basic_annotation.vcf.gz* /shuffle/projects/chipdesign/variant_calling/trypanogen/X/
ln -s /shuffle/projects/chipdesign/variant_calling/trypanogen/cross_impute_ready/trypanogen.X.vqsr.cross_impute_ready.basic_annotation.vcf.gz* /shuffle/projects/chipdesign/variant_calling/trypanogen/X/

/opt/exp_soft/bcftools/bcftools merge -m none /shuffle/projects/chipdesign/variant_calling/trypanogen/X/trypanogen.X_PAR1.vqsr.cross_impute_ready.basic_annotation.vcf.gz /shuffle/projects/chipdesign/variant_calling/trypanogen/X/trypanogen.X.vqsr.cross_impute_ready.basic_annotation.vcf.gz -O z -o /shuffle/projects/chipdesign/variant_calling/trypanogen/X/trypanogen.X.male.female.vqsr.cross_impute_ready.basic_annotation.vcf.gz

/opt/exp_soft/tabix-0.2.6/tabix /shuffle/projects/chipdesign/variant_calling/trypanogen/X/trypanogen.X.male.female.vqsr.cross_impute_ready.basic_annotation.vcf.gz
