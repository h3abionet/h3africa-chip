#!/bin/bash

# SAHGP only have males so we should treat the set differently but keep the naming the naming the same as the other sets so that we can combine later

# First sort out pre VQSR VCFs
ln -s /shuffle/projects/chipdesign/variant_calling/sahgp/genotype_gvcfs_with_basic_annotation/sahgp.X_PAR1.basic_annotation.vcf.gz /shuffle/projects/chipdesign/variant_calling/sahgp/X/sahgp.X.male.female.basic_annotation.vcf.gz
ln -s /shuffle/projects/chipdesign/variant_calling/sahgp/genotype_gvcfs_with_basic_annotation/sahgp.X_PAR1.basic_annotation.vcf.gz.tbi  /shuffle/projects/chipdesign/variant_calling/sahgp/X/sahgp.X.male.female.basic_annotation.vcf.gz.tbi

# Then sort out post VQSR VCFs
ln -s /shuffle/projects/chipdesign/variant_calling/sahgp/cross_impute_ready/sahgp.X_PAR1.vqsr.cross_impute_ready.basic_annotation.vcf.gz /shuffle/projects/chipdesign/variant_calling/sahgp/X/sahgp.X.male.female.vqsr.cross_impute_ready.basic_annotation.vcf.gz
ln -s /shuffle/projects/chipdesign/variant_calling/sahgp/cross_impute_ready/sahgp.X_PAR1.vqsr.cross_impute_ready.basic_annotation.vcf.gz.tbi /shuffle/projects/chipdesign/variant_calling/sahgp/X/sahgp.X.male.female.vqsr.cross_impute_ready.basic_annotation.vcf.gz.tbi


