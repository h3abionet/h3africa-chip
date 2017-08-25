#!/bin/bash
. $config

#module add R/3.0.0

set -x

start_time=$(date +%s)

java -Xmx$gatk_vqsr_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar  \
-T VariantRecalibrator \
-input $genotyped_vcf \
-R $ref_seq \
-an DP \
-an QD \
-an FS \
-an MQ \
-an MQRankSum \
-an ReadPosRankSum \
-an InbreedingCoeff \
-an SOR \
--mode SNP \
-resource:hapmap,known=false,training=true,truth=true,prior=15.0 $hapmap_sites \
-resource:omni,known=false,training=true,truth=true,prior=12.0 $omni_sites \
-resource:1000G,known=false,training=true,truth=false,prior=10.0 $kgp_phase1_snp_sites \
-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $dbsnp_sites \
$site \
-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 98.5 -tranche 98.0 -tranche 97.5 -tranche 97.0 -tranche 96.5 -tranche 96.0 -tranche 95.5 -tranche 95.0 -tranche 94.5 -tranche 94.0 -tranche 93.5 -tranche 93.0 -tranche 92.5 -tranche 92.0 -tranche 91.5 -tranche 91.0 -tranche 90.5 -tranche 90.0 \
-nt $gatk_vqsr_data_threads \
-nct $gatk_vqsr_cpu_threads_per_data_thread \
-recalFile $vqsr_snps_recal \
-tranchesFile $vqsr_snps_tranches \
-rscriptFile $vqsr_snps_rscript

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
