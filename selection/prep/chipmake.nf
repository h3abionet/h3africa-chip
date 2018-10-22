


params.label = "S"

freq_ch =  Channel.fromPath(params.freq_dir)



bad_ch  =  Channel.fromPath("/spaces/scott/chip/pool_selection/badscore60.snps")

extra_ch = Channel.fromPath("/spaces/scott/chip/extras/*").toList()


max_run = 1023

process freqTable {
  cpus 8
  input:
      file fdir from freq_ch
  output:
      file 'maf_tbl.cpickle' into maf_table_ch
  script:
      template  "pgetfreqs.py"
}


process poolSelect {

  input:
     file maf_tbl   from maf_table_ch
     file bad_snps  from bad_ch
     file extras_list from extra_ch
  output:
      file(${out}.stats)  into stats_ch
      file(${out}.lst)     into list_ch
      file(${out}.trg)    into trg_ch
      val $out into label_ch
  each run in 0..max_run
   
  script:
     out  = "P-${params.label}-${run}"
     reqs =extras_list.join(",")
     """
     python pool_select.py --input $maf_tbl  --label $out --bad $bad_snps --requests  $reqs --factor 1.5 $run 10 18
    """
}


process findOptimalIsh {
  input:
     file stats from stats_ch.toList()
     file lists from list_ch.toList()
     file targets from target_ch.toList()
     val label from label_ch.toList()
  output:
     set file("pools.stats"), file("pools.sel"), file("pools.trg") into chosen_ch
  script:
     template "findbest.py"
}


process selectChoice {
  input:
     set file (stats), file (base_selected), file(target) from best_ch
  output:
     file 

  script:
     python gtldex.py --pops cbio-30-04,sanger-rev-30-04 --limit 2489000 --batch 10000  R1-NN-01

