#Scripts for the evaluation of genotyping arrays

#############################################################################
1. eval_cov_ld_nt.pl

The script based on Ha et al. 2014 paper estimates the Coverage, LD efficiency and NT efficiency of a genotyping array for a reference dataset.

The four inputs for the script are -
ldfile  - a PLINK LD output file for the reference population
bimfile - a PLINK bim File containing the list of SNPs in the reference
chipfile - a PLINK Bim file containing list of SNPs in the chip
LD cutoff -LD cutoff to be used for assigning taggability 0.1, 0.2...0.9
G - Expected totral number of SNPs in the genome


#
The PLINK LD file can be generated in a two step process. 
The reference genome in the example is in the PLINK binary format (ref.bed, ref.bim, ref.fam)
The first step involves a MAF based filtering and removal of indels
plink --autosome --bfile ref --maf 0.01 --make-bed --out ref_filtered --snps-only
The second step calculates LD between SNP pairs:
plink --bfile ref_filtered --ld-window-kb 300 --ld-window-r2 0.01 --out ref_ld --r2


# The output columns report-
LD efficiency
NT efficiency
Coverage

Line 105 if uncommented reports the actual number and other stats involved.

#############################################################################
2. eval_win.pl
The script eval estimates the same stats as eval_cov_ld_nt.pl but at the level of user defined windows.
In addition to the 5 parameters as in eval_cov_eff_nt.pl the script requires an additional parameter window size which should be the length of window in base pairs.

The output columns report 
Chromosome number
Window start
Window end
LD effinciency (for the window)
NT effinciency (for the window)
Coverage (for the window)

Lines 145, 151,173 and 177, if uncommented, can generate additional details.

