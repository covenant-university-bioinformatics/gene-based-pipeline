#!/bin/bash

##### eMAGMA
## To Run ./eMAGMA.sh UK_pval-N.txt afr [No drop ...]


####### Downloading files
## wget https://ctg.cncr.nl/software/MAGMA/prog/magma_v1.09b.zip
### wget https://ctg.cncr.nl/software/MAGMA/aux_files/NCBI37.3.zip
### wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_eur.zip
### wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_afr.zip
### wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_eas.zip
### wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_sas.zip
### wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_amr.zip
### wget https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_subpop.zip

##

#./eMAGMA.sh emagma_test.txt output_folder afr no 0 0

set -x	## To debug

binary_dir="/mnt/d/eqtl/binary"

gwas_summary=$1;
output_dir=$2;
population=$3; #  {afr, amr, eur, eas, sas}
synonym=$4;  # Accounting for synonymous SNP IDs
#### synonyms=No -- > suppress automatically loading, to speed up the process
#### synonym-dup=drop  -->  SNPs that have multiple synonyms in the data are removed from the analysis
#### synonym-dup=drop-dup -->  for each synonym entry only the first listed in the synonym file is retained;
#### synonym-dup=skip ---> the SNPs are left in the data and the synonym entry in the synonym file is skipped.
#### synonym-dup=skip-dup --->  the genotype data for all synonymous SNPs is retained.
#### if not provided i.e NA --> same as skip

if [[ "$synonym" -eq "" ]]; then
  synonym=Default;
fi
output_prefix=Gene_set;  ####

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
#### Parameters:
## 1. Adding an annotation window around genes in kb
up_window=$5 #5
down_window=$6 #6

if [[ "$up_window" -eq "" ]]; then
  up_window=0;
fi

if [[ "$down_window" -eq "" ]]; then
  down_window=0;
fi


#./eMAGMA.sh emagma_test.txt output_folder afr no 0 0

$binary_dir/magma --annotate window=${up_window},${down_window} --snp-loc $gwas_summary --gene-loc ${binary_dir}/NCBI/NCBI37.3.gene.loc \
--out ${output_dir}/$output_prefix; ## NCBI to binary_dir

##intermediate output files
## Tow output files: 1- ${output_prefix}.genes.raw 2- ${output_prefix}.genes.annot

###############Gene-based MAGMA
#### Tow senarios:
### 1. SNPs' pvalues are not provided in GWAS Summary. However, this needs GWAS raw data, which is not our  case
### 2- SNPs' pvalues  are provided.
### synonym-dup modifier

## Oupt file ---> ${output_prefix}.genes.out
### senario 2

##### Parameters:
## 1. gene-model ----> Specifying the gene analysis model
## 2. burden ---->  Specifying burden score settings for rare variants



if [[ "$synonym" == "No" ]]; then
$binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonyms=0 \
--gene-annot ${output_dir}/${output_prefix}.genes.annot \
--pval $gwas_summary ncol=N \
--gene-settings adap-permp=1001 \
--big-data \
--out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "drop" ]]; then
  $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=drop \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=1001 \
  --big-data \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "drop-dup" ]]; then
  $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=drop-dup \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=1001 \
  --big-data \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "skip" ]]; then
  $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=skip \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=1001 \
  --big-data \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "skip-dup" ]]; then
  $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=skip-dup \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=1001 \
  --big-data \
  --out ${output_dir}/$output_prefix;
else
  $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population  \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=1001 \
  --big-data \
  --out ${output_dir}/$output_prefix;
fi

## Oupt file ---> ${output_prefix}.genes.out
#annotate the snps based on the genes
#for each gene, it returns the number of SNPs
#Header;
#GENE       CHR    START     STOP  NSNPS  NPARAM      N        ZSTAT            P        PERMP  NPERM


tissue=$7

############# tissues
#1.  Adipose_Subcutaneous
#2.  Adipose_Visceral_Omentum
#3.  Adrenal_Gland
#4.  Artery_Aorta
#5.  Artery_Coronary
#6.  Artery_Tibial
#7.  Brain_Amygdala
#8.  Brain_Anterior_cingulate_cortex_BA24
#9.  Brain_Caudate_basal_ganglia
#10. Brain_Cerebellar_Hemisphere
#11. Brain_Cerebellum
#12. Brain_Cortex
#13. Brain_Frontal_Cortex_BA9
#14. Brain_Hippocampus
#15. Brain_Hypothalamus
#16. Brain_Nucleus_accumbens_basal_ganglia
#17. Brain_Putamen_basal_ganglia
#18. Brain_Spinal_cord_cervical_c-1
#19. Brain_Substantia_nigra
#20. Breast_Mammary_Tissue
#21. Cells_EBV-transformed_lymphocytes
#22. Colon_Sigmoid
#23. Colon_Transverse
#24. Esophagus_Gastroesophageal_Junction
#25. Esophagus_Mucosa
#26. Esophagus_Muscularis
#27. Heart_Atrial_Appendage
#28. Heart_Left_Ventricle
#29. Liver
#30. Lung
#31. Minor_Salivary_Gland
#32. Muscle_Skeletal
#33. Nerve_Tibial
#34. Ovary
#35. Pancreas
#36. Pituitary
#37. Prostate
#38. Skin_Not_Sun_Exposed_Suprapubic
#39. Skin_Sun_Exposed_Lower_leg
#40. Small_Intestine_Terminal_Ileum
#41. Spleen
#42. Stomach
#43. Testis
#44. Thyroid
#45. Uterus
#46. Vagina
#47. Whole_Blood

### Please note the number of tissues is 47 not 48, as indicated on GitHub --->
### --> this because  the "Cells_Transformed_fibroblasts.genes.annot" is missing in emagma_anno_3.tar.gz

if [[ "$tissue" != "" ]]; then
    if [[ "$synonym" == "No" ]]; then
    $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonyms=0 \
    --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
    --pval $gwas_summary ncol=N \
    --gene-settings adap-permp=1001 \
    --big-data \
    --out ${output_dir}/${output_prefix}.${tissue};
    elif  [[ "$synonym" == "drop" ]]; then
      $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=drop \
      --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
      --pval $gwas_summary ncol=N \
      --gene-settings adap-permp=1001 \
      --big-data \
      --out ${output_dir}/${output_prefix}.${tissue};
    elif  [[ "$synonym" == "drop-dup" ]]; then
      $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=drop-dup \
      --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
      --pval $gwas_summary ncol=N \
      --gene-settings adap-permp=1001 \
      --big-data \
      --out ${output_dir}/${output_prefix}.${tissue};
    elif  [[ "$synonym" == "skip" ]]; then
      $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=skip \
      --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
      --pval $gwas_summary ncol=N \
      --gene-settings adap-permp=1001 \
      --big-data \
      --out ${output_dir}/${output_prefix}.${tissue};
    elif  [[ "$synonym" == "skip-dup" ]]; then
      $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=skip-dup \
      --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
      --pval $gwas_summary ncol=N \
      --gene-settings adap-permp=1001 \
      --big-data \
      --out ${output_dir}/${output_prefix}.${tissue};
    else
      $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population  \
      --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
      --pval $gwas_summary ncol=N \
      --gene-settings adap-permp=1001 \
      --big-data \
      --out ${output_dir}/${output_prefix}.${tissue};
    fi

    Rscript --vanilla ${binary_dir}/Genes.R ${output_dir}/${output_prefix}.${tissue}.genes.out ${binary_dir}/NCBI/NCBI37.3.gene.loc
fi

#### pathway analysis
#### We decided to do pathway analysis in Pascal

#### Reformat gene set Output file by adding genes'
## Oupt file ---> ${output_prefix}.genes.out i.e overwrite the file

Rscript --vanilla ${binary_dir}/Genes.R ${output_dir}/${output_prefix}.genes.out ${binary_dir}/NCBI/NCBI37.3.gene.loc

#### Plots input file
### Tow plots: 1- qq.svg; 2- manhattan.svg

Rscript --vanilla ${binary_dir}/plot_qq_manhattan.R ${gwas_summary} ${output_dir}
