#!/bin/bash
#. config.txt
. $config

start_time=$(date +%s)

java -Xmx$gatk_hc_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar  \
-T HaplotypeCaller \
-R $ref_seq \
-I $bam \
--emitRefConfidence GVCF --variant_index_type LINEAR --variant_index_parameter 128000 \
--dbsnp $dbsnp_sites \
$site \
-gt_mode DISCOVERY \
-A Coverage -A FisherStrand -A StrandOddsRatio -A HaplotypeScore -A MappingQualityRankSumTest -A QualByDepth -A RMSMappingQuality -A ReadPosRankSumTest \
-stand_call_conf 30 \
-stand_emit_conf 30 \
--sample_ploidy  $ploidy \
--disable_auto_index_creation_and_locking_when_reading_rods \
-nt $gatk_hc_data_threads \
-nct $gatk_hc_cpu_threads_per_data_thread \
-o $vcf

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
