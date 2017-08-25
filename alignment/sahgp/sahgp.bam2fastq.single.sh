#!/bin/bash
#. config.txt
. $config

dirname=$(dirname $bam)
filename=$(basename $bam)
ext=${filename##*.}
base=${filename%%.bam}


fifo_1=$tmp_dir/$filename.fifo_1
fifo_2=$tmp_dir/$filename.fifo_2
rm -f $fifo_1
rm -f $fifo_2

mkfifo $fifo_1
mkfifo $fifo_2

cat $fifo_1 | gzip -c > $dirname/$base.f1.fastq.gz &
cat $fifo_2 | gzip -c > $dirname/$base.f2.fastq.gz &

start_time=$(date +%s)
java -Xmx$bam2fastq_mem -Djava.io.tmpdir=$tmp_dir -jar $picard_base/SamToFastq.jar  \
INPUT=$bam \
FASTQ=$fifo_1 \
SECOND_END_FASTQ=$fifo_2 \
VALIDATION_STRINGENCY=LENIENT

rm $fifo_1
rm $fifo_2

end_time=$(date +%s)
diff_time=$(( $end_time - $start_time ))
echo "$diff_time seconds"
echo "`echo "scale=2;$diff_time/60" | bc` minutes"
