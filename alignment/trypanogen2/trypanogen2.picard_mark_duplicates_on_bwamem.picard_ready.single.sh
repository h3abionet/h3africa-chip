#!/bin/bash
. $config
/opt/gridware/bioinformatics/python/python_2.7.5/bin/python /export/home/gbotha/projects/h3abionet/chipdesign/helpers/ps_tracker/pstracker.py -p $$ -t 60 -o $pstracker_log_path.${PBS_JOBID}.pstracker &
start_time=$(date +%s)

echo -n "Hostname: ";hostname

echo "" > $pstracker_log_path.${PBS_JOBID}.cmds  

### Mark duplicates
cmd="java -Xmx$picard_mark_duplicates_mem -Djava.io.tmpdir=$tmp_dir -jar $picard_base/MarkDuplicates.jar  \
INPUT=$bam \
OUTPUT=$marked_duplicates_bam \
METRICS_FILE=$marked_duplicates_metrics \
CREATE_INDEX=true"

echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds
`eval $cmd`

### Index the bam (Let's see if it gets indexed by MarkDuplicates)
#$samtools_base/samtools index $marked_duplicates_bam

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
