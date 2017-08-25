To prepare the per source VCFs (baylor, sahgp and trypanogen) for phasing, the wrapper *get_union_vcf_and_replace_missing_sites.batch.sh* needs to be run.

 It is driven by "config.txt" and the following scripts:

1. The union of the post VQSR baylor, sahgp and trypanogen sites (*get_union_post_vqsr.single.sh*),
2. the pre VQSR VCF on the post VQSR union sites (*get_union_pre_vqsr.single.sh*) and 
3. replacing all missing genotypes in the pre VQSR VCF with 0/0 (*get_union_pre_vqsr_replace_missing.single.sh*).

The scripts could have been constructed better but for now it is doing what needs to be done.

At the moment only chr 1 to 22, X_PAR1 and X are being processed. X_PAR2, X_nonPAR, Y_PAR1, Y_PAR2 and Y_nonPAR, MT were not successfully being VQSRed so that still needs to be looked into.

Other things in this folder

1. *hc_sites.list* - Haplotype Caller sites. BUild from coordinates in $gatk_resource_bundle/human_g1k_v37_decoy.fasta.fai and ftp://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/All/GCF_000001405.25.regions.txt
2. Variant calling pipeline diagrams
3. Folders for sources (sahgp, baylor, trypanogen) containing variant calling pipeline scripts for each source.

For emile I had to merge all the sets (baylor, trypanogen< sahgp) once all the sites were VQSRed. `get_union_vcf_and_replace_missing_sites.batch.sh` ran and that in turn called `get_union_post_vqsr.single.sh`, `get_union_pre_vqsr.single.sh` and `get_union_pre_vqsr_replace_missing.single.sh`.

 


