#!/bin/bash
. $config

set -x

start_time=$(date +%s)

cmd="$bcftools_base/bcftools annotate -x INFO,FORMAT/AD,FORMAT/GQ,FORMAT/DP,FORMAT/PGT,FORMAT/PID $vcf -O z -o $vcf_with_basic_annotation"
echo $cmd
eval $cmd
 
cmd="$tabix_base/tabix -p vcf $vcf_with_basic_annotation"
echo $cmd
eval $cmd

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
