#!/bin/bash
DEBUG=0

queue=H3A
config=/export/home/gbotha/projects/h3abionet/chipdesign/bam_improvement/trypanogen/config.txt
# For the PBS settings we need to get the mem, cpu, and queue settings
. $config

verifybamid_dir=$verifybamid_dir
logs_dir=$logs_dir"/select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid"`date +"%y%m%d%H%M%S"`
mkdir $logs_dir 

# start pipeline
sample_count=1

verifybamid_persample_stats_list=trypanogen.select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.batch.verifyBamID_stats_list

echo $samtools_calmd_dir
echo $variant_call_ready_dir

while read verifybamid_persample_stats;
do
  file_name=$(basename $verifybamid_persample_stats);
  sample_id=${file_name%%.bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bqsr.calmd.verifyBamID.selfSM}
  bam=$samtools_calmd_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bqsr.calmd.bam"
  bai=$samtools_calmd_dir/$sample_id".bwa.sorted.picard_marked_duplicates.gatk_realigned.mate_fixed.bqsr.calmd.bai"

  echo "" > $logs_dir/select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.$sample_id.$sample_count.o 

  if [ $DEBUG -eq 1 ]
  then
    echo $verifybamid_persample_stats
    echo $bam
  else 
    echo "TrypanoGEN: $sample_id"
    
    cat $config > $logs_dir/select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.$sample_id.$sample_count.config
    printf $verifybamid_persample_stats" : " >> $logs_dir/select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.$sample_id.$sample_count.o ; cat $verifybamid_persample_stats | awk -F$"\t" 'BEGIN {line_count=1}(line_count==2){freemix=$7}{line_count+=1} END{print freemix}' | awk -v bam=$bam -v bai=$bai -v variant_call_ready_dir=$variant_call_ready_dir -F " " '{if ( $1<0.05 ) {print "freemix < 0.05, keep this sample"; system("ln -s "bam" "variant_call_ready_dir); system("ln -s "bai" "variant_call_ready_dir)} else {print "freemix >= 0.05, discard this sample"} }' >> $logs_dir/select_variant_call_ready_on_bwamem.picard_ready.mark_duplicates_gatk_realign_bqsr.samtools_calmd.verifybamid.$sample_id.$sample_count.o
  fi

  (( sample_count+=1 ))

done < $verifybamid_persample_stats_list
