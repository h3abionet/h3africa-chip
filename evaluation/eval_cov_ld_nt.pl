#!/usr/bin/perl -w

my $ldfile=$ARGV[0]; #plink LD output file
my $bimfile=$ARGV[1]; # File containing the list of SNPs in the reference
my $chipfile=$ARGV[2]; #Bim file containing list of SNPs in the chip
my $cutoff= $ARGV[3]; #LD cutoff to be used for assigning taggability 0.1, 0.2...0.9
my $G=$ARGV[4]; #Expected totral number of SNPs in the genome

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
##

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
##

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


my ($eld,$ent,$cov,$CR,$CR1)=getstats($tchip,$tref,$schip,$sref,$snp_chip,$snp_ref,$m,"1",$G);

print $eld,"\t",$ent,"\t",$cov,"\n";

#Uncomment the following line to print the actual numbers
#print $cutoff,"\t",$tref,"\t", ,$sref,"\t",$snp_ref,"\t",$tchip,"\t",$schip,"\t",$snp_chip,"\t",$eld,"\t",$ent,"\t",$cov,"\t","$m\n";


####################################################################
sub getstats{

my($tchip,$tref,$schip,$sref,$snp_chip,$snp_ref,$m,$winsize,$G)=@_;


#my $snp_chip2=$snp_chip+$m;
my $snp_chip2=$snp_chip;

#Efficiency parameters
my $eff_ld=sprintf("%.2f",($tchip/$tref)*(1-($snp_chip2/$snp_ref)));
my $eff_nt=sprintf("%.2f",($schip/$sref)*(1-($snp_chip2/$snp_ref)));

#Calculating coverage
my $R=$snp_ref;
my $T=$snp_chip;
my $L=$tchip;
my $va=$L/($R-$T);
my $CR=sprintf("%.2f",($va*($G-$T)+$T)/$G);

my $R1=$R+$m;
my $T1=$T+$m;
my $L1=($T1/$T)*$L;
my $vb=$L1/($R1-$T1);
my $CR1=sprintf("%.2f",($vb*($G-$T1)+$T1)/$G);


if($CR>1){$CR=1;}
if($CR1>1){$CR1=1;}
my $cov=sprintf("%.2f",($CR+$CR1)/2);
return($eff_ld,$eff_nt,$cov,$CR,$CR1)
}

########################################################################
