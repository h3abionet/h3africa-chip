This step was run on the CBIO cluster (CHPC was down for maintenance from the 8/1/2016)

HaplotypeCaller on each sample was run at Blue Waters. The Blue Waters generated GVCFs was used as input to the following steps.

1. *baylor.genotype_gvcfs.batch.sh*
2. *baylor.vqsr.batch.sh*
3. *baylor.apply_vqsr.batch.sh*
4. *baylor.prepare_for_cross_impute.batch.sh*

Running baylor.hc.dm.batch.sh on chromosome 1 and 2 took too long. The GATK recommendation is to split samples into batches of 200. So to run it like that (only ready for chromosome 1 to 22):

1. *baylor.combine_gvcfs.batch.sh*
2. *baylor.genotype_gvcfs_on_combine_gvcfs.batch.sh*
3. *baylor.vqsr.batch.sh*
4. *baylor.apply_vqsr.batch.sh*
5. *baylor.prepare_for_cross_impute.batch.sh* (the naming of this file and output files it generates are wrong, it should actually be something like prep for merging of sets/ make ready for phasing)
6. *baylor.prepare_basic_annotation.genotype_gvcfs.batch.sh* (strip annotation from pre VQSR VCFs)
7. *baylor.prepare_basic_annotation.prepare_for_cross_impute.batch.sh* (strip annotation from post VQSR VCFs)
8. *baylor.annotate.batch.sh* (annnotate post VQSR VCF with dbNSP 146)




