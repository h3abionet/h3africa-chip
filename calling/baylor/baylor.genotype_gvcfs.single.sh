#!/bin/bash
#. config.txt
. $config

start_time=$(date +%s)
 
java -Xmx$gatk_genotype_gvcfs_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar  \
-T GenotypeGVCFs \
-R $ref_seq \
-A InbreedingCoeff -A FisherStrand -A StrandOddsRatio -A QualByDepth -A ChromosomeCounts -A GenotypeSummaries -A MappingQualityRankSumTest -A ReadPosRankSumTest -A StrandBiasBySample -A VariantType \
$site \
-stand_call_conf 30 \
-stand_emit_conf 30 \
-V $gvcf_list \
-nt $gatk_genotype_gvcfs_data_threads \
-nct $gatk_genotype_gvcfs_cpu_threads_per_data_thread \
-o $vcf

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
