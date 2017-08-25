#!/bin/bash
. $config

set -x

start_time=$(date +%s)

export BCFTOOLS_PLUGINS=/opt/exp_soft/bcftools/plugins/
$bcftools_base/bcftools +missing2ref $pre_vqsr_union_vcf -O z -o $pre_vqsr_union_replace_missing_vcf".tmp"
$tabix_base/tabix -p vcf $pre_vqsr_union_replace_missing_vcf".tmp"

$bcftools_base/bcftools norm -c s -f $ref_seq -m->snps $pre_vqsr_union_replace_missing_vcf".tmp" -O z -o $pre_vqsr_union_replace_missing_vcf
$tabix_base/tabix -p vcf $pre_vqsr_union_replace_missing_vcf

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
