#!/bin/bash
. $config

set -x

start_time=$(date +%s)

java -Xmx$gatk_vqsr_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar  \
-T ApplyRecalibration \
-input $genotyped_vcf \
-R $ref_seq \
--mode SNP \
--ts_filter_level 99.5 \
-recalFile $vqsr_snps_recal \
-tranchesFile $vqsr_snps_tranches \
$site \
-nt $gatk_apply_vqsr_data_threads \
-nct $gatk_apply_vqsr_cpu_threads_per_data_thread \
-o $apply_vqsr_vcf

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
