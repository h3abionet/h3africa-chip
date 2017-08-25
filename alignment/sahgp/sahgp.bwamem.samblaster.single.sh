#!/bin/bash
. $config
start_time=$(date +%s)
/opt/gridware/bioinformatics/python/python_2.7.5/bin/python /export/home/gbotha/projects/h3abionet/chipdesign/helpers/ps_tracker/pstracker.py -p $$ -t 60 -o $logs_dir/$log_id.${PBS_JOBID}.pstracker &
$bwa_base/bwa mem -R  $bam_readgroup_info -M -t $bwamem_threads $ref_seq $f1 $f2 | $samblaster_base/samblaster | $samtools_base/samtools view -ubhS - > $md_bam
end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
