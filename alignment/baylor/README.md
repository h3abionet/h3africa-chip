We are running the Baylor pipeline on two samples so that we can compare it with the output from the runs at Blue Waters

1. *baylor.bwamem.picard_ready.batch* - bwa alignment and then coordinate sorting and indexing for Picard 
2. *baylor.picard_mark_duplicates_gatk_realign_bqsr_on_bwamem.picard_ready.batch.sh* - pipeline for marking duplicates (with Picard), local realignment, and base quality recalibration on Picard ready bwa aligned bams. This script calls:
  1. *baylor.picard_mark_duplicates_on_bwamem.picard_ready.single.sh* - mark duplicates with Picard
  2. *baylor.gatk_local_realign_on_picard_marked_duplicates.bwamem.picard_ready.single.sh* - GATK local realignment
  3. *baylor.gatk_bqsr_on_gatk_local_realign.picard_marked_duplicates.bwamem.picard_ready.single.sh* 
3. *baylor.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.batch.sh*  - run samtools calmd
4. *baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.batch.sh* - run verifyBamID on the samtools calmd bams
5. *baylor.select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.batch.sh* - check if the freemix statistic per sample < 0.05 and then create a softlink to the calmd bams if passed.
6. *sahgp.flagstat.batch.sh* - getting the sam flagstats for a list of bams (Optional). 
7. *config.txt* - PATH, software and input/output settings. Reference and db settings. Tool memory, cpu and wall time requirements.

The following output directories need to be created:

logs_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/baylor/logs
picard_ready_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/baylor/picard_ready
picard_marked_duplicates_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/baylor/picard_marked_duplicates
gatk_local_realigned_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/baylor/gatk_local_realigned
gatk_bqsr_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/baylor/gatk_bqsr
samtools_calmd_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/baylor/samtools_calmd
verifybamid_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/baylor/verifybamid
variant_call_ready_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/baylor/variant_call_ready
flagstat_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/baylor/flagstat

Sample id / bam lists needs to be created before launcing scripts

1. *baylor.bwamem.picard_ready.batch* needs *baylor.bwamem.picard_ready.batch.sample_dir_list* (sample directory listing)
2. *baylor.picard_mark_duplicates_gatk_realign_bqsr_on_bwamem.picard_ready.batch.sh* needs *baylor.picard_mark_duplicates_gatk_realign_bqsr_on_bwamem.picard_ready.batch.bam_list*  (bam listing)
3. *baylor.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.batch.sh* needs baylor.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.batch.bam_list (bam listing)
4. *baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.batch.sh* needs baylor.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.batch.bam_list (bam listing)
5. *baylor.select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.batch.sh* needs baylor.select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.verifyBamID_stats_list (verifyBamID .selfSM listing)
6. *sahgp.flagstat.batch.sh* needs baylor.flagstat.batch.bam_list (bam listing)
