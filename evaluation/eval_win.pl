#!/usr/bin/perl -w

my $ldfile=$ARGV[0]; #plink LD output file
my $bimfile=$ARGV[1]; # File containing the list of SNPs in the reference
my $chipfile=$ARGV[2]; #Bim file containing list of SNPs in the chip
my $cutoff= $ARGV[3]; #LD cutoff to be used for assigning taggability 0.1, 0.2...0.9
my $G=$ARGV[4]; #Expected totral number of SNPs in the genome
my $lengthWin=$ARGV[5]; #Length of window to use for scanning

## Counting the total number of SNPs in reference and loading the SNPs to a hash
my %ref=(); my @refsnps=();
my $snp_ref=0;
open(BIM,$bimfile);
while(<BIM>){ 
chomp($_);
@tabs=split("\t",$_);
$pos=$tabs[0]."_".$tabs[3];
push(@refsnps,$pos);
$ref{$pos}="N";
$snp_ref++;
}
close BIM;


#Counting the total number of SNPs in the chip and loading the SNPs to a hash
my %chip=();
my $snp_chip=0;
open(CHIP,$chipfile);
while(<CHIP>){
chomp($_);
@tabs=split("\t",$_);
$pos=$tabs[0]."_".$tabs[3];
$chip{$pos}="N";
$snp_chip++;
}
close CHIP;


#Identifying taggable SNPs in reference
my %tagsnps=();
my $tc=0;
my %chipt=();
my %chip_tagged=();
open(LDF,$ldfile);
my $fl=<LDF>;
while(<LDF>){
chomp($_);
@tabs=split(/\s+/,$_);
$snpA=$tabs[1]."_".$tabs[2];
$snpB=$tabs[4]."_".$tabs[5];
$ld=$tabs[7];

if($ld>=$cutoff){
	if(exists($chip{$snpA})){$chip_tagged{$snpB}="T";$chipt{$snpA}="T";}
	if(exists($chip{$snpB})){$chip_tagged{$snpA}="T";$chipt{$snpB}="T";}

	if(exists($tagsnps{$snpA})){;}
	else{$tagsnps{$snpA}="T";}
	if(exists($tagsnps{$snpB})){;}
	else{$tagsnps{$snpB}="T";}
	}

}

#Identifying non-taggable SNPs in reference and counting the number of taggable and non taggable SNPs
my %nontags=();
my $tref=0;my $sref=0;
my @ntr=();my $ntrc=0;
while(my ($key,$value)=each %ref){
    if(exists($tagsnps{$key})){$tref++;}
    else{
        $sref++;
        $nontags{$key}=$key;
    }
}


#Number of SNPs in chip which are absent in reference
my $m=0;my $comm=0;my @pnp=();
while(my($keyb,$valueb)=each %chip){
    if(exists($ref{$keyb})){$comm++}
    else{$m++;push(@pnp,$keyb);}
}



#Identifying the number of taggable and non taggable SNPs in chip
my $tchip_o=0;my $schip=0;
while(my ($key,$value)=each %chip){
    if(exists($tagsnps{$key})){$tchip_o++;}
    if(exists($nontags{$key})){$schip++;}
}

#Total SNPs in the reference which are tagged by the SNPs in chip
my $tchip=0;
while(my ($key,$value)=each %ref){
if(exists($chip_tagged{$key})){$tchip++;}
}

##Running the scan per window

my $chr=1;
my $minch=1;
my $maxch=22;
my $start=1;
my $winsize= $lengthWin;
my $slide=$lengthWin;
my $end=($start+$winsize)-1;
my($ch,$pos,$coord)=("","","","","","");
my($refc,$chipc,$tagref,$tagchip,$ntref,$ntchip,$tagchip_o)=(0,0,0,0,0,0,0);

foreach $coord (@refsnps){
($ch,$pos)=split("_",$coord);
START:
if($chr>$maxch){last;}
    
    if($ch eq $chr){
        if($pos>=$start and $pos<=$end){
        $refc++;
        if(exists($chip{$coord})){
	$chipc++;
   	if(exists($tagsnps{$coord})){$tagchip_o++;}
        if(exists($nontags{$coord})){$ntchip++;}
	}
 
        if(exists($tagsnps{$coord})){$tagref++;}
        if(exists($nontags{$coord})){$ntref++}
	if(exists($chip_tagged{$coord})){$tagchip++;}
        }

        else{

        $pnpc=0;
        foreach(@pnp){
        @cur=split("_",$_);
        if($cur[0] eq $ch){if($cur[1]>=$start and $cur[1]<=$end){$pnpc++;}}
	elsif($cur[0] eq $ch){if($cur[1]>$end){last;}}
        }

         if($refc>0 and $tagref>0 and $ntref>0 and $chipc>0){
         ($eld,$ent,$cov)=getstats($tagchip,$tagref,$ntchip,$ntref,$chipc,$refc,$pnpc,$winsize,$G);


         print $chr,"\t",$start,"\t",$end,"\t","$eld\t$ent\t$cov","\n";
         #print $chr,"\t",$start,"\t",$end,"\t","$tagchip\t$tagref\t$ntchip\t$ntref\t",$chipc,"\t$refc\t$eld\t$ent\t$cov","\t",$pnpc,"\t",$tagchip_o,"\n";
	}

	else{

        print $chr,"\t",$start,"\t",$end,"\t","$eld\t$ent\t$cov","\n";
        #print $chr,"\t",$start,"\t",$end,"\t","$tagchip\t$tagref\t$ntchip\t$ntref\t",$chipc,"\t$refc\t-\t-\t-","\t",$pnpc,"\t",$tagchip_o,"\n";
	}
 
            $refc=0;$chipc=0;$tagchip=0;$tagref=0;$ntchip=0;$ntref=0;$tagchip_o=0;
            $start=$start+$slide;
            $end=$end+$slide;
            goto START;
        }
    }
    
    
    else{
        $pnpc=0;
        foreach(@pnp){
        @cur=split("_",$_);
        if($cur[0] eq $chr){if($cur[1]>=$start and $cur[1]<=$end){$pnpc++;}}
        }

	if($refc>0 and $tagref>0 and $ntref>0 and $chipc>0){
	($eld,$ent,$cov)=getstats($tagchip,$tagref,$ntchip,$ntref,$chipc,$refc,$pnpc,$winsize,$G);

        print $chr,"\t",$start,"\t",$end,"\t","$eld\t$ent\t$cov","\n";
        #print $chr,"\t",$start,"\t",$end,"\t","$tagchip\t$tagref\t$ntchip\t$ntref\t",$chipc,"\t$refc\t$eld\t$ent\t$cov","\t",$pnpc,"\t",$tagchip_o,"\n";
	}
	else{
        print $chr,"\t",$start,"\t",$end,"\t","$eld\t$ent\t$cov","\n";
        #print $chr,"\t",$start,"\t",$end,"\t","$tagchip\t$tagref\t$ntchip\t$ntref\t",$chipc,"\t$refc\t-\t-\t-","\t",$pnpc,"\t",$tagchip_o,"\n";
	}

        $chr=$chr+1;
        $refc=0;$chipc=0;$tagchip=0;$tagref=0;$ntchip=0;$ntref=0;$tagchip_o=0;
        $start=1;
        $end=$start+$winsize-1;
        goto START;
    }
    
}

####################################################################
sub getstats{

my($tchip,$tref,$schip,$sref,$snp_chip,$snp_ref,$m,$winsize,$WG)=@_;

#my $snp_chip2=$snp_chip+$m;

my $snp_chip2=$snp_chip+0;

#Efficiency parameters
my $eff_ld=sprintf("%.2f",($tchip/$tref)*(1-($snp_chip2/$snp_ref)));
my $eff_nt=sprintf("%.2f",($schip/$sref)*(1-($snp_chip2/$snp_ref)));

#Calculating coverage
if($winsize==1){$G=$WG;}# Estiamting the total number of SNPs in genome
else{ 
my $winfrac=3000000000/$winsize;
$G= $WG/$winfrac;
} #Estimate of the Total number of SNPs in window
my $R=$snp_ref;
my $T=$snp_chip;
my $L=$tchip;
my $va=$L/($R-$T);
my $pCR=($va*($G-$T)+$T)/$G;
my $CR=sprintf("%.2f",($va*($G-$T)+$T)/$G);

my $R1=$R+$m;
my $T1=$T+$m;
my $L1=($T1/$T)*$L;
my $vb=$L1/($R1-$T1);

my $pCR1=($vb*($G-$T1)+$T1)/$G;
my $CR1=sprintf("%.2f",($vb*($G-$T1)+$T1)/$G);


if($CR>1){$CR=1;}
if($CR1>1){$CR1=1;}
my $cov=sprintf("%.2f",($pCR+$pCR1)/2);
return($eff_ld,$eff_nt,$cov)
}

########################################################################
