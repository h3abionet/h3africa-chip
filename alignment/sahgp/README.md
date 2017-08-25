### Folder contain scripts related to align, mark duplicates and do GATK bam improvement on the 24 genomes of SAHGP (only the Sotho (02) and Xhosa (03) bams will be used in variant calling). The SAHGP alignment->bam improvement are done on sample level.
1. *sahgp.bam2fastq.single.sh* - convert FTS binned bams to fastq
2. *sahgp.bwamem.samblaster.batch.sh* - bwa alignment and marked duplicates with samblaster 
3. *sahgp.samblaster.on_picard_ready.batch.sh* - name sorting of picard ready files and then piping to samblaster (this was just used for testing purposes) 
4. *sahgp.bwamem.picard_ready.batch* - bwa alignment and then coordinate sorting and idexing for Picard
5. *sahgp.picard_mark_duplicates_gatk_realign_bqsr_on_bwamem.picard_ready.batch.sh* - pipeline for marking duplicates (with Picard), local realignment, and base quality recalibration on Picard ready bwa aligned bams. This script calls:
  1. *sahgp.picard_mark_duplicates_on_bwamem.picard_ready.single.sh* - mark duplicates with Picard
  2. *sahgp.gatk_local_realign_on_picard_marked_duplicates.bwamem.picard_ready.single.sh* - GATK local realignment
  3. *sahgp.gatk_bqsr_on_gatk_local_realign.picard_marked_duplicates.bwamem.picard_ready.single.sh* - GATK BQSR
6. *sahgp.samtools_calmd_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.batch.sh*  - run samtools calmd
7. *sahgp.verifybamid_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.batch.sh* - run verifyBamID on the samtools calmd bams
8. *sahgp.select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.batch.sh* - check if the freemix statistic per sample < 0.05 and then create a softlink to the calmd bams if passed.
8. *sahgp.flagstat.batch.sh* - getting the sam flagstats for a list of bams. 
9. *config.txt* - PATH, software and input/output settings. Reference and db settings. Tool memory, cpu and wall time requirements.





