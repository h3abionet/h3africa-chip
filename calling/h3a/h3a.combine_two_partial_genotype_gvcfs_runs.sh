#/bin/bash

DEBUG=0
in_part1=$1
in_part2=$2
out=$3
chr=$4

echo "base path in_part1:" $in_part1
echo "base path in_part2:" $in_part2
echo "base path out:" $out
echo "chr:" $chr

# Lets make a folder for every chromosome we work one
cmd="mkdir -p $out/$chr"
echo $cmd
if [ $DEBUG -eq 0 ]; then eval $cmd; fi

out="$out/$chr"

# Get everything except the last line
cmd="zcat $in_part1/h3a.$chr.vcf.gz | head -n -1 > $out/h3a.$chr.part1.cut.vcf"
echo $cmd
if [ $DEBUG -eq 0 ]; then eval $cmd; fi

# Now prepare a vcf.gz from this partial VCF
cmd="/opt/exp_soft/tabix-0.2.6/bgzip $out/h3a.$chr.part1.cut.vcf"
echo $cmd
if [ $DEBUG -eq 0 ]; then eval $cmd; fi
cmd="/opt/exp_soft/tabix-0.2.6/tabix -p vcf $out/h3a.$chr.part1.cut.vcf.gz"
echo $cmd
if [ $DEBUG -eq 0 ]; then eval $cmd; fi

# Now combine the two sets
cmd="/opt/exp_soft/bcftools/bcftools concat -o $out/h3a.$chr.vcf.gz -O z $out/h3a.$chr.part1.cut.vcf.gz $in_part2/h3a.$chr.vcf.gz"
echo $cmd
if [ $DEBUG -eq 0 ]; then eval $cmd; fi
cmd="/opt/exp_soft/tabix-0.2.6/tabix -p vcf $out/h3a.$chr.vcf.gz"
echo $cmd
if [ $DEBUG -eq 0 ]; then eval $cmd; fi

# Just get some stats to check if concat numbers matches up
cmd="/opt/exp_soft/bcftools/bcftools stats $out/h3a.$chr.part1.cut.vcf.gz > $out/h3a.$chr.part1.cut.vcf.gz.stat"
echo $cmd
if [ $DEBUG -eq 0 ]; then eval $cmd; fi
cmd="/opt/exp_soft/bcftools/bcftools stats $in_part2/h3a.$chr.vcf.gz > $out/h3a.$chr.part2.vcf.gz.stat"
echo $cmd
if [ $DEBUG -eq 0 ]; then eval $cmd; fi
cmd="/opt/exp_soft/bcftools/bcftools stats $out/h3a.$chr.vcf.gz > $out/h3a.$chr.vcf.gz.stat"
echo $cmd 
if [ $DEBUG -eq 0 ]; then eval $cmd; fi
