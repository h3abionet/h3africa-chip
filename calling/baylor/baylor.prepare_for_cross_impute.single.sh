#!/bin/bash
. $config

set -x

start_time=$(date +%s)

# When we applied VQSR to SNPs it also emitted INDELS in the original VCF as unchanged so we have to remove them.
snps_only_vcf=$(basename $apply_vqsr_vcf)
snps_only_vcf=$tmp_dir/$snps_only_vcf.snps_only.vcf.gz

java -Xmx$prepare_cross_impute_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar  \
-T SelectVariants  \
--variant $apply_vqsr_vcf \
$site \
-R $ref_seq \
-selectType SNP \
-nt $gatk_prepare_cross_impute_data_threads \
-nct $gatk_prepare_cross_impute_cpu_threads_per_data_thread \
-o $snps_only_vcf


# Sites with `.` would've hopefully been removed when we -selectType SNP. All SNP sites woudle've been filtered/PASSED by VQSR and those not would've been flagged with `.'`
# So now lets just inlucde PASS sites with 

java -Xmx$prepare_cross_impute_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar  \
-T SelectVariants  \
--variant $snps_only_vcf \
$site \
-R $ref_seq \
--excludeFiltered \
-nt $gatk_prepare_cross_impute_data_threads \
-nct $gatk_prepare_cross_impute_cpu_threads_per_data_thread \
-o $cross_impute_ready_vcf

# IGNORE the commented code parts for now. Will keep all the info from GATK.

#-o $no_indels_vcf

# Now lets remove INFO from VCF, might need to remove some more later or not at all. Not sure.
# Lets strip off the .gz and sort out the compression at the end
#tmp_vcf="${cross_impute_ready_vcf%.*}"

#/opt/exp_soft/vcftools_0.1.12b/bin/vcftools --gzvcf $no_indels_vcf --remove-filtered-all --recode --out $tmp_vcf

#mv $tmp_vcf.recode.vcf $tmp_vcf

#/opt/exp_soft/tabix-0.2.6/bgzip $tmp_vcf
#/opt/exp_soft/tabix-0.2.6/tabix -p vcf $cross_impute_ready_vcf

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
