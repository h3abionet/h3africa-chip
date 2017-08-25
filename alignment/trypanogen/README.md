1. *trypanogen.bwamem.picard_ready.batch* - bwa alignment and then coordinate sorting and idexing for Picard
2. *trypanogen.picard_mark_duplicates_gatk_realign_bqsr_on_bwamem.picard_ready.batch.sh* - pipeline for marking duplicates (with Picard), local realignment, and base quality recalibration on Picard ready bwa aligned bams. This script calls:
  1. *trypanogen.picard_mark_duplicates_on_bwamem.picard_ready.single.sh* - mark duplicates with Picard
  2. *trypanogen.gatk_local_realign_on_picard_marked_duplicates.bwamem.picard_ready.single.sh* - GATK local realignment
  3. *trypanogen.gatk_bqsr_on_gatk_local_realign.picard_marked_duplicates.bwamem.picard_ready.single.sh* - GATK BQSR
3. *trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.batch.sh*  - run samtools calmd
4. *trypanogen.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.batch.sh* - run verifyBamID on the samtools calmd bams
5. *trypanogen.select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.batch.sh* - check if the freemix statistic per sample < 0.05 and then create a softlink to the calmd bams if passed.
6. *sahgp.flagstat.batch.sh* - getting the sam flagstats for a list of bams (Optional). 
7. *config.txt* - PATH, software and input/output settings. Reference and db settings. Tool memory, cpu and wall time requirements.

The following output directories need to be created:

logs_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/trypanogen/logs
picard_ready_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/trypanogen/picard_ready
picard_marked_duplicates_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/trypanogen/picard_marked_duplicates
gatk_local_realigned_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/trypanogen/gatk_local_realigned
gatk_bqsr_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/trypanogen/gatk_bqsr
samtools_calmd_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/trypanogen/samtools_calmd
verifybamid_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/trypanogen/verifybamid
variant_call_ready_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/trypanogen/variant_call_ready
flagstat_dir=/lustre/SCRATCH5/groups/h3a/chipdesign/bam_improvement/trypanogen/flagstat

Sample id / bam lists needs to be created before launcing scripts

1. *trypanogen.bwamem.picard_ready.batch* needs *trypanogen.bwamem.picard_ready.batch.sample_dir_list* (sample directory listing)
2. *trypanogen.picard_mark_duplicates_gatk_realign_bqsr_on_bwamem.picard_ready.batch.sh* needs *trypanogen.picard_mark_duplicates_gatk_realign_bqsr_on_bwamem.picard_ready.batch.bam_list*  (bam listing)
3. *trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.batch.sh* needs trypanogen.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.batch.bam_list (bam listing)
4. *trypanogen.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.batch.sh* needs trypanogen.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.batch.bam_list (bam listing)
5. *trypanogen.select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.batch.sh* needs trypanogen.select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.verifyBamID_stats_list (verifyBamID .selfSM listing)
6. *sahgp.flagstat.batch.sh* needs trypanogen.flagstat.batch.bam_list (bam listing)
