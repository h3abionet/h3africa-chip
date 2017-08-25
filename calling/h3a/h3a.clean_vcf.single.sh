#!/bin/bash
. $config

set -x

start_time=$(date +%s)

# We want SNPS only but also sites with no variation. The no variation sites were introduced when we recalled and we need them if we want to merge with the Sanger set later.

java -Xmx$prepare_cross_impute_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar  \
-T SelectVariants  \
--variant $genotyped_vcf \
$site \
-R $ref_seq \
-selectType SNP \
-selectType NO_VARIATION \
-nt $gatk_prepare_cross_impute_data_threads \
-nct $gatk_prepare_cross_impute_cpu_threads_per_data_thread \
-o $clean_vcf 

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
