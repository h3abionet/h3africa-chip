#!/bin/bash
. $config
/opt/gridware/bioinformatics/python/python_2.7.5/bin/python /export/home/gbotha/projects/h3abionet/chipdesign/helpers/ps_tracker/pstracker.py -p $$ -t 60 -o $pstracker_log_path.${PBS_JOBID}.pstracker &
start_time=$(date +%s)

# Loading modules here
MODULEPATH=/opt/gridware/bioinformatics/modules:$MODULEPATH
source /etc/profile.d/modules.sh

module add verifyBamID/1.1.1

# For now runnning the SAHGP data without incorporating genotype data. The Baylor samples should be run like this (using the 1000G Omni 2.5 allele set and running with --chip-none.
verifyBamID --vcf $verifybamid_1000G_omni25_alleles --bam $bam --out $verifybamid_prefix --verbose --ignoreRG --chip-none 

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
