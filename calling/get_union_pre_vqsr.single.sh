#!/bin/bash
. $config

set -x

start_time=$(date +%s)

# Not using GATK here anymore
#java -Xmx$gatk_combine_variants_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar  \
#-T CombineVariants \
#--variant $genotype_gvcfs_vcf_baylor \
#--variant $genotype_gvcfs_vcf_sahgp \
#--variant $genotype_gvcfs_vcf_trypanogen \
#-L $post_vqsr_union_vcf \
#-R $ref_seq \
#-nt $gatk_combine_variants_data_threads \
#-nct $gatk_combine_variants_cpu_threads_per_data_thread \
#--genotypemergeoption REQUIRE_UNIQUE  \
#-o $pre_vqsr_union_vcf

$bcftools_base/bcftools merge -R $post_vqsr_union_vcf -m none $genotype_gvcfs_vcf_baylor $genotype_gvcfs_vcf_sahgp $genotype_gvcfs_vcf_trypanogen -O z -o $pre_vqsr_union_vcf
$tabix_base/tabix -p vcf $pre_vqsr_union_vcf

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
