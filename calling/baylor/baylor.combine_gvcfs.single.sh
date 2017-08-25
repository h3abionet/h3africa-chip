#!/bin/bash
#. config.txt
. $config

start_time=$(date +%s)
 
java -Xmx$gatk_genotype_gvcfs_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar  \
-T CombineGVCFs \
-R $ref_seq \
$site \
-V $gvcf_list \
-nt $gatk_combine_gvcfs_data_threads \
-nct $gatk_combine_gvcfs_cpu_threads_per_data_thread \
-o $vcf

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
