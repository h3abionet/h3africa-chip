This step was run on the CBIO cluster (CHPC was down for maintenance from the 8/1/2016)

1. *trypanogen.hc.dm.batch.sh* - Main script to submit individual HaplotypeCaller in Discovery mode jobs. Jobs are broken down into sites per sample.
2. *trypanogen.genotype_gvcfs.batch.sh*
3. *trypanogen.vqsr.batch.sh*
4. *trypanogen.apply_vqsr.batch.sh*
5. *trypanogen.prepare_for_cross_impute.batch.sh* (the naming of this file and output files it generates are wrong, it should actually be something like prep for merging of sets/ make ready for phasing)
6. *trypanogen.prepare_basic_annotation.genotype_gvcfs.batch.sh* (strip annotation from pre VQSR VCFs)
7. *trypanogen.prepare_basic_annotation.prepare_for_cross_impute.batch.sh* (strip annotation from post VQSR VCFs)
