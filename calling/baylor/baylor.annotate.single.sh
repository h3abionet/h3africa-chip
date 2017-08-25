#!/bin/bash
. $config

set -x

start_time=$(date +%s)

$cross_impute_ready_vcf

java -Xmx$annotate_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar  \
-T VariantAnnotator  \
--variant $cross_impute_ready_vcf \
$site \
-R $ref_seq \
-nt $gatk_annotate_data_threads \
-nct $gatk_annotate_cpu_threads_per_data_thread \
--dbsnp $latest_dbsnp \
-o $annotate_vcf

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
