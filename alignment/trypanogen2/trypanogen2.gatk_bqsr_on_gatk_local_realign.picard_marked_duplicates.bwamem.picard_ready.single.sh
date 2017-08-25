#!/bin/bash
. $config
/opt/gridware/bioinformatics/python/python_2.7.5/bin/python /export/home/gbotha/projects/h3abionet/chipdesign/helpers/ps_tracker/pstracker.py -p $$ -t 60 -o $pstracker_log_path.${PBS_JOBID}.pstracker &
start_time=$(date +%s)

echo -n "Hostname: ";hostname

echo "" > $pstracker_log_path.${PBS_JOBID}.cmds

### Generate the recalibration table
cmd="java -Xmx$gatk_bqsr_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar \
-T BaseRecalibrator  \
-R $ref_seq \
-nt $gatk_bqsr_data_threads \
-nct $gatk_bqsr_cpu_threads_per_data_thread \
-knownSites $dbsnp_sites \
-knownSites $kgp_phase1_indel_sites \
-knownSites $mills_and_1000G_indel_sites \
-I $bam \
-o $gatk_bqsr_table \
--disable_auto_index_creation_and_locking_when_reading_rods"

echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds
`eval $cmd`

### Recalibrate bam from table
cmd="java -Xmx$gatk_bqsr_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar \
-T PrintReads \
-R $ref_seq \
-I $bam \
-BQSR $gatk_bqsr_table \
-o $gatk_bqsr_bam"

echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds
`eval $cmd`

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
