#!/usr/bin/env bash

##### eMAGMA
## To Run ./eMAGMA.sh UK_pval-N.txt afr 0


####### Downloading files
## wget https://ctg.cncr.nl/software/MAGMA/prog/magma_v1.09b.zip
## wget https://ctg.cncr.nl/software/MAGMA/aux_files/NCBI37.3.zip
## wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_eur.zip
## wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_afr.zip
## wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_eas.zip
## wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_sas.zip
## wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_amr.zip
## wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_subpop.zip

##



set -x	## To debug


input_dir=".";
output_dir=".";
binary_dir="."

gwas_summary=$1;
population=$2; #  {afr, amr, eur, eas, sas}
synonym=$3;  # Accounting for synonymous SNP IDs
#### synonyms=0 -- > suppress automatically loading, to speed up the process
#### synonym-dup=drop  -->  SNPs that have multiple synonyms in the data are removed from the analysis
#### synonym-dup=drop-dup -->  for each synonym entry only the first listed in the synonym file is retained;
#### synonym-dup=skip ---> the SNPs are left in the data and the synonym entry in the synonym file is skipped.
#### synonym-dup=skip-dup --->  the genotype data for all synonymous SNPs is retained.
####  if not provided i.e NA --> same as skip

if [[ "$synonym" -eq "0" ]]; then
  synonym=Default;
fi


output_prefix=Testing_gene_set;

#### Input GWAS Summary columns
## 1- SNP-ID its name SNP
## 2- chromosome
## 3- base pair position,
## 4- P-value information Its name P
## 5. Sample size its name is  N


#### Step 1 Annotation step
#### This step  a pre-processing step prior to the actual analysis
## The input for this step is a GWAS Summary
## The should has at least 3 columns, which are:
## 1- SNP ID
## 2- chromosome
## 3- base pair position


##### $gwas_summary contains full path to inpput GWAS Summary file
magma --annotate --snp-loc $gwas_summary --gene-loc ${input_dir}/NCBI/NCBI37.3.gene.loc \
--out ${output_dir}/$output_prefix;


###############Gene-based MAGMA
#### Tow senarios:
### 1. SNPs' pvalues are not provided in GWAS Summary. However, this needs GWAS raw data, which is not our  case
### 2- SNPs' pvalues  are provided.
### synonym-dup modifier

### senario 2
if [[ "$synonym" == "0" ]]; then
magma --bfile ${input_dir}/g1000/g1000_$population synonyms=0 \
--gene-annot ${output_dir}/${output_prefix}.genes.annot \
--pval $gwas_summary ncol=N \
--gene-settings adap-permp=10000 \
--out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "drop" ]]; then
  magma --bfile ${input_dir}/g1000/g1000_$population synonym-dup=drop \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "drop-dup" ]]; then
  magma --bfile ${input_dir}/g1000/g1000_$population synonym-dup=drop-dup \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "skip" ]]; then
  magma --bfile ${input_dir}/g1000/g1000_$population synonym-dup=skip \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "skip-dup" ]]; then
  magma --bfile ${input_dir}/g1000/g1000_$population synonym-dup=skip-dup \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
else
  magma --bfile ${input_dir}/g1000/g1000_$population  \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
fi

########### Select significant genes  using the Bonferroni correction
#### Step calculating number of genes
#num_genes=$( expr $(wc -l ${output_dir}/$output_prefix.genes.out | cut -d ' '  -f 1 ) - 1
#significance_level= $( expr 0.05 / $num_genes ) -------------> rewrite this usig awk
## awk -v genes=num_genes '{if ($9<=(0.05/genes)) print $0}' ${output_dir}/$output_prefix.genes.out > ${output_dir}/$output_prefi_signif_genes.txt
##awk '{if ($9<=3.8431e-5) print $0}' ${output_dir}/${output_prefix}.genes.out > ${output_dir}/${output_prefix}_signif_genes.txt




#################### eQTL networks analysis
## col indicating the index for the gene ID column and gene-set name column respectively

#### 1. synapse
magma --gene-results ${output_dir}/${output_prefix}.genes.raw --set-annot ${input_dir}/geneSets/synapse.sets col=1,2 --out ${output_dir}/synapse
#plot
Rscript --vanilla ${binary_dir}/plots.R ${output_dir}/synapse.gsa.out ${input_dir}/geneSets/synapse_clusters.index  ${output_dir}/synapse

#### 2. glia-astrocytes.sets
magma --gene-results ${output_dir}/${output_prefix}.genes.raw --set-annot ${input_dir}/geneSets/glia-astrocytes.sets col=1,2 --out ${output_dir}/glia-astrocytes
#plot
Rscript --vanilla ${binary_dir}/plots.R ${output_dir}/glia-astrocytes.gsa.out ${input_dir}/geneSets/glia-astrocytes_clusters.index  ${output_dir}/glia-astrocytes

#### 3. glia-microglia.sets
magma --gene-results ${output_dir}/${output_prefix}.genes.raw --set-annot ${input_dir}/geneSets/glia-microglia.sets col=1,2 --out ${output_dir}/glia-microglia
#plot
Rscript --vanilla ${binary_dir}/plots.R ${output_dir}/glia-microglia.gsa.out ${input_dir}/geneSets/glia-microglia_clusters.index  ${output_dir}/glia-microglia

#### 4. glia-oligodendrocytes.sets
magma --gene-results ${output_dir}/${output_prefix}.genes.raw --set-annot ${input_dir}/geneSets/glia-oligodendrocytes.sets col=1,2 --out ${output_dir}/glia-oligodendrocytes
#plot
Rscript --vanilla ${binary_dir}/plots.R ${output_dir}/glia-oligodendrocytes.gsa.out ${input_dir}/geneSets/glia-oligodendrocytes_clusters.index  ${output_dir}/glia-oligodendrocytes
