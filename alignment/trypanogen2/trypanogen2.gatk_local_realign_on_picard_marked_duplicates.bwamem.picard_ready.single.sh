#!/bin/bash
. $config
/opt/gridware/bioinformatics/python/python_2.7.5/bin/python /export/home/gbotha/projects/h3abionet/chipdesign/helpers/ps_tracker/pstracker.py -p $$ -t 60 -o $pstracker_log_path.${PBS_JOBID}.pstracker &
start_time=$(date +%s)

echo -n "Hostname: ";hostname

echo "" > $pstracker_log_path.${PBS_JOBID}.cmds

### Get table of possible indels (need to check if this can be run in parallel)
cmd="java -Xmx$gatk_local_realign_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-R $ref_seq \
-I $bam \
-nt $gatk_local_realign_data_threads \
-nct $gatk_local_realign_cpu_threads_per_data_thread \
-o $gatk_realign_list"

echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds
`eval $cmd`

### Do the indel realignment
# Multi-threading is not available for IndelRealigner
cmd="java -Xmx$gatk_local_realign_mem -Djava.io.tmpdir=$tmp_dir -jar $gatk_base/GenomeAnalysisTK.jar \
-T IndelRealigner \
-R $ref_seq \
-I $bam  \
-targetIntervals $gatk_realign_list \
-known $kgp_phase1_indel_sites \
-known $mills_and_1000G_indel_sites \
-o $gatk_realigned_bam \
--disable_auto_index_creation_and_locking_when_reading_rods"

echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds
`eval $cmd`

### Keep mate information fixed
cmd="java -Xmx$gatk_local_realign_mem -Djava.io.tmpdir=$tmp_dir -jar $picard_base/FixMateInformation.jar \
INPUT=$gatk_realigned_bam \
OUTPUT=$picard_mate_fixed_bam \
SORT_ORDER=coordinate \
VALIDATION_STRINGENCY=LENIENT \
CREATE_INDEX=true"

echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds
`eval $cmd`

### Index the bam (do not think there is need for this anymore), because it is already sorted by FixMateInformation)
#$samtools_base/samtools index $picard_mate_fixed_bam 

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
