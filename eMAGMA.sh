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
#### synonyms=No -- > suppress automatically loading, to speed up the process
#### synonym-dup=drop  -->  SNPs that have multiple synonyms in the data are removed from the analysis
#### synonym-dup=drop-dup -->  for each synonym entry only the first listed in the synonym file is retained;
#### synonym-dup=skip ---> the SNPs are left in the data and the synonym entry in the synonym file is skipped.
#### synonym-dup=skip-dup --->  the genotype data for all synonymous SNPs is retained.
#### if not provided i.e NA --> same as skip

if [[ "$synonym" -eq " " ]]; then
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
## Tow output files: 1- ${output_prefix}.genes.raw 2- ${output_prefix}.genes.annot
magma --annotate --snp-loc $gwas_summary --gene-loc ${binary_dir}/NCBI/NCBI37.3.gene.loc \
--out ${output_dir}/$output_prefix; ## NCBI to binary_dir


###############Gene-based MAGMA
#### Tow senarios:
### 1. SNPs' pvalues are not provided in GWAS Summary. However, this needs GWAS raw data, which is not our  case
### 2- SNPs' pvalues  are provided.
### synonym-dup modifier

## Oupt file ---> ${output_prefix}.genes.out
### senario 2
if [[ "$synonym" == "No" ]]; then
magma --bfile ${binary_dir}/g1000/g1000_$population synonyms=0 \
--gene-annot ${output_dir}/${output_prefix}.genes.annot \
--pval $gwas_summary ncol=N \
--gene-settings adap-permp=10000 \
--out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "drop" ]]; then
  magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=drop \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "drop-dup" ]]; then
  magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=drop-dup \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "skip" ]]; then
  magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=skip \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "skip-dup" ]]; then
  magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=skip-dup \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
else
  magma --bfile ${binary_dir}/g1000/g1000_$population  \
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

#### 1. synapse  ---> output file -->synapse.gsa.out
magma --gene-results ${output_dir}/${output_prefix}.genes.raw --set-annot ${binary_dir}/geneSets/synapse.sets col=1,2 --out ${output_dir}/synapse
#plot  ---> output file -->synapse.svg
Rscript --vanilla ${binary_dir}/plots.R ${output_dir}/synapse.gsa.out ${binary_dir}/geneSets/synapse_clusters.index  ${output_dir}/synapse

#### 2. glia-astrocytes.sets  ---> output file -->glia-astrocytes.gsa.out
magma --gene-results ${output_dir}/${output_prefix}.genes.raw --set-annot ${binary_dir}/geneSets/glia-astrocytes.sets col=1,2 --out ${output_dir}/glia-astrocytes
#plot  ---> output file -->glia-astrocytes.svg
Rscript --vanilla ${binary_dir}/plots.R ${output_dir}/glia-astrocytes.gsa.out ${binary_dir}/geneSets/glia-astrocytes_clusters.index  ${output_dir}/glia-astrocytes

#### 3. glia-microglia.sets  ---> output file -->glia-microglia.gsa.out
magma --gene-results ${output_dir}/${output_prefix}.genes.raw --set-annot ${binary_dir}/geneSets/glia-microglia.sets col=1,2 --out ${output_dir}/glia-microglia
#plot  ---> output file -->glia-microglia.svg
Rscript --vanilla ${binary_dir}/plots.R ${output_dir}/glia-microglia.gsa.out ${binary_dir}/geneSets/glia-microglia_clusters.index  ${output_dir}/glia-microglia

#### 4. glia-oligodendrocytes.sets   ---> output file -->glia-oligodendrocytes.gsa.out
magma --gene-results ${output_dir}/${output_prefix}.genes.raw --set-annot ${binary_dir}/geneSets/glia-oligodendrocytes.sets col=1,2 --out ${output_dir}/glia-oligodendrocytes
#plot ---> output file -->glia-oligodendrocytes.svg
Rscript --vanilla ${binary_dir}/plots.R ${output_dir}/glia-oligodendrocytes.gsa.out ${binary_dir}/geneSets/glia-oligodendrocytes_clusters.index  ${output_dir}/glia-oligodendrocytes



#### Reformat gene set Output file by adding genes'
## Oupt file ---> ${output_prefix}.genes.out i.e overwrite the file

Rscript --vanilla ${binary_dir}/Genes.R ${output_dir}/${output_prefix}.genes.out ${binary_dir}/NCBI/NCBI37.3.gene.loc

#### Plots input file
### Tow plots: 1- qq.svg; 2- manhattan.svg
Rscript --vanilla ${binary_dir}/plot_qq_manhattan.R $GWAS_summary $output_dir
