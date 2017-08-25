#!/bin/bash
. $config
/opt/gridware/bioinformatics/python/python_2.7.5/bin/python /export/home/gbotha/projects/h3abionet/chipdesign/helpers/ps_tracker/pstracker.py -p $$ -t 60 -o $pstracker_log_path.${PBS_JOBID}.pstracker &
start_time=$(date +%s)
echo -n "Hostname: ";hostname

echo "" > $pstracker_log_path.${PBS_JOBID}.cmds  

prefix="${bam%.*}"

cmd="$bwa_base/bwa mem -R  \"$bam_readgroup_info\" -M -t $bwamem_threads $ref_seq $f1 $f2 | $samtools_base/samtools view -ubhS - | $samtools_base/samtools sort - $prefix"

echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds  
`eval $cmd`

cmd="$samtools_base/samtools index $bam"
echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds  
`eval $cmd`

cmd="mv $bam.bai $bai"
echo $cmd >> $pstracker_log_path.${PBS_JOBID}.cmds  
`eval $cmd`

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
