#!/bin/bash
. $config

set -x

start_time=$(date +%s)

java -Xmx$gatk_combine_variants_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar  \
-T CombineVariants \
--variant $cross_impute_ready_vcf_baylor \
--variant $cross_impute_ready_vcf_sahgp \
--variant $cross_impute_ready_vcf_trypanogen \
$site \
-R $ref_seq \
-nt $gatk_combine_variants_data_threads \
-nct $gatk_combine_variants_cpu_threads_per_data_thread \
--genotypemergeoption REQUIRE_UNIQUE  \
--minimalVCF \
-o $post_vqsr_union_vcf

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
