#!/bin/bash
. $config
start_time=$(date +%s)
$bwa_base/bwa mem -R  $bam_readgroup_info -M -t $bwamem_threads $ref_seq $f1 $f2 | $samtools_base/samtools view -ubhS - | $samtools_base/samtools sort - $picard_ready_dir/$sample_id."bwa.sorted"
end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
