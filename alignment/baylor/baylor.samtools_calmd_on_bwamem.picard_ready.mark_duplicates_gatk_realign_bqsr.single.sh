#!/bin/bash
. $config
/opt/gridware/bioinformatics/python/python_2.7.5/bin/python /export/home/gbotha/projects/h3abionet/chipdesign/helpers/ps_tracker/pstracker.py -p $$ -t 60 -o $pstracker_log_path.${PBS_JOBID}.pstracker &
start_time=$(date +%s)

echo -n "Hostname: ";hostname

echo "" > $pstracker_log_path.${PBS_JOBID}.cmds  

cmd="$samtools_base/samtools calmd -Erb $bam $ref_seq > $samtools_calmd_bam"
echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds
`eval $cmd`


cmd="$samtools_base/samtools index $samtools_calmd_bam"
echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds
`eval $cmd`

cmd="mv $samtools_calmd_bam.bai $samtools_calmd_bai"
echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds
`eval $cmd`

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
