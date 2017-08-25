#!/bin/bash
. $config
start_time=$(date +%s)
#$samtools_base/samtools view -h $bam | $samblaster_base/samblaster | $samtools_base/samtools view -Sb - > $md_bam
$samtools_base/samtools  sort -n $bam -o $bam.dummy | $samtools_base/samtools view -h - | $samblaster_base/samblaster | $samtools_base/samtools view -ubhS - > $md_bam
end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
