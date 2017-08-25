1. *sahgp.hc.dm.batch.sh* - Main script to submit individual HaplotypeCaller in Discovery mode jobs. Jobs are broken down into sites per sample.
2. *sahgp.genotype_gvcfs.batch.sh*
3. *sahgp.vqsr.batch.sh*
4. *sahgp.apply_vqsr.batch.sh*
5. *sahgp.prepare_for_cross_impute.batch.sh* (the naming of this file and output files it generates are wrong, it should actually be something like prep for merging of sets/ make ready for phasing)
6. *sahgp.prepare_basic_annotation.genotype_gvcfs.batch.sh* (strip annotation from pre VQSR VCFs)
7. *sahgp.prepare_basic_annotation.prepare_for_cross_impute.batch.sh* (strip annotation from post VQSR VCFs)
