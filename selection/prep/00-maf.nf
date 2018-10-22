#!/usr/bin/env nextflow


import java.nio.file.Paths




aux_data = params.aux_data
out_dir  = params.out_dir
sanger   = params.sanger
cbio     = params.cbio

File f = new File(aux_data+'groups.txt')


cbio_indivs  = Paths.get(aux_data,"cbio").toString()
sanger_indivs= Paths.get(aux_data,"sanger").toString()
mydir=file(out_dir)
mydir.mkdir()


pop2group = ["dummy":"dummy"]



pop = Channel.create()


f.eachLine { text, lineNumber ->
   data = text.split()
   group = data[0]
   mydir=file(out_dir+"$group")
   mydir.mkdir()
   data[1..data.length-1].each {pop.bind(it); pop2group[it]=group}
   
}

pop.close()


process getIndivs {
   input:
     val pop
   tag { pop }
   output:
     file "${pop}.indivs" into pop_indivs
   """
     grep $pop /global/chpdes/scott/samples.phe | cut -f 1 > /tmp/${pop}.indivs
     paste /tmp/${pop}.indivs /tmp/${pop}.indivs > ${pop}.indivs
   """
}

chroms = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22]


process getVCF {
   memory '10GB'
   publishDir "/dataB/popdata/VCF_CBIO_SANGER/groups2/${pop2group[pop]}/", overwrite:true, mode:'copy'
   errorStrategy 'ignore'
   cpus   1
   input:
      file pop_indivs
   each chrom from chroms
   tag { pop }
   output:
   set val(pop), file("${pop}-${chrom}.bed"),file("${pop}-${chrom}.bim"),file("${pop}-${chrom}.fam") into plink_ch
   script:
      pop = pop_indivs.baseName
      """ 
        x=`head -n1 $pop_indivs | cut -f 1`
	if grep \$x $cbio_indivs >& /dev/null ; then
           plink --double-id --biallelic-only strict --vcf $sanger/sanger_chr${chrom}.vcf.gz --keep $pop_indivs --make-bed --out /tmp/${pop}-${chrom} 
        elif grep \$x $sanger_indivs >& /dev/null ; then
           plink --double-id --biallelic-only strict  --vcf $cbio/h3a.${chrom}.cleaned.vcf.gz --keep $pop_indivs --make-bed --out /tmp/${pop}-${chrom} 
        else
	   echo "$pop <\$x>  PRIBL"
        fi
        mv /tmp/${pop}-${chrom}.* .
      """
 
}



process freqDo {
   memory '10GB'
   maxForks 10
  input:
   set val(pop), file(bed), file(bim), file(fam) from plink_ch
   publishDir "${out_dir}/frq/${pop2group[pop]}/", overwrite:true, mode:'copy'
   output:
      file "*frq"
      val "ready" into ready_ch
   script:
     base = bed.baseName
   """
      hostname
      bimidfix.sh ${base}.bim
      plink --bfile $base --freq --out $base
   """
}


fdir_ch = Channel.fromPath("${out_dir}/frq")
process freqTable {
  cpus 10
   memory '30GB'
  input:
      file fdir from fdir_ch
      val ready from ready_ch.toList()
      publishDir "${out_dir}"
   publishDir "/dataB/popdata/VCF_CBIO_SANGER/"
  output:
      file 'maf_tbl.cpickle' into maf_table_ch
  script:
      template "pgetfreqs.py"
}


maf_table_ch.subscribe { print "Ready -- produced $it\n " }
