

<img src="aux/H3ABioNetlogo2.jpg"/>

# Code used in design of the H3A Genotyping array


## alignment

Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah 

## calling

Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah Blah blah blah blah 


## selection

This contains the code that is used for selecting SNPs


### pools

Code for doing pool selection

* `pool_select.py`  This is the main script that does pool selection. They key parameters are
  * `--input` a cpickle object with the scores of the individual SNPs and used to score the pools
  * `--label` a label used to name output files
  * `--bad`  the list of SNPs which have a bad design score
  * `--requests`  SNPs we really want and are given an extra plus 
  * `--factor` Affects the scoring function -- see the paper 1.5 or 1 -- doesn't make much difference
  * three positional arguments: a run number, a bit width, b, how many steps are done exhaustively. The pools are ordered greedily by score. The run number is a number between 0 and (2^b)-1. The way we interpret the run number is as set representation of the first b pools -- a 1 if the pool is selected and a 0 if not. So a given run number pre-selects which of the first b pools should be included in this run. We parallelise (see chip.sh) by running the pool_selection 2^b times in parallel, once for run number. The choice of b depends on the level of parallelism you can support

* `chip.sh`  An example PBS script that runs the pool selection 


### prep : creates the frequency table

Creates the pickle object that the above uses

* `00-maf.nf` : Nextflow workflow to create the pickle object
* `chipmake.nf`: Incomplete code to make a workflow for everything


### tag algorithm

*  `gtldex2.py` : representative script

```usage: gtldex2.py [-h] [--good_snpsd GOOD] [--bad_snp BAD_F]
                  [--twobeadsnps TWOBEADF] [--preselect PRESEL]
                  [--haplodir HAPLODIR] --pops POPS [--limit LIMIT]
                  [--batch BATCH] [--exons EXONS]
                  outf

Check for for unbalanced windows.

positional arguments:
  outf                  name of output file

optional arguments:
  -h, --help            show this help message and exit
  --good_snpsd GOOD     Directory with good snps
  --bad_snp BAD_F       Directory with good snps
  --twobeadsnps TWOBEADF
                        file of SNPs that require two beads
  --preselect PRESEL    directory with custom complex
  --haplodir HAPLODIR   Directory PLINK haplo blocks file can be found
  --pops POPS           Comma separated list of populations (prefix of fnames)
  --limit LIMIT         total cost of chip
  --batch BATCH         batch size in distribution
  --exons EXONS         File where exons can be found
```



### Auxiliary scripts

* `showgaps.py` : summarises gaps in the chip
* `windowshopper.py` : takes our chips and a bunch of other chips, regions we're not happy about, and finds SNPs that other chips have that we don't that should be included.



