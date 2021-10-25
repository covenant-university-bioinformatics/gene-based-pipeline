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
--gene-settings adap-permp=10000 \
--out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "drop" ]]; then
  $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=drop \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "drop-dup" ]]; then
  $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=drop-dup \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "skip" ]]; then
  $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=skip \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
elif  [[ "$synonym" == "skip-dup" ]]; then
  $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=skip-dup \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
else
  $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population  \
  --gene-annot ${output_dir}/${output_prefix}.genes.annot \
  --pval $gwas_summary ncol=N \
  --gene-settings adap-permp=10000 \
  --out ${output_dir}/$output_prefix;
fi

## Oupt file ---> ${output_prefix}.genes.out
#annotate the snps based on the genes
#for each gene, it returns the number of SNPs
#Header;
#GENE       CHR    START     STOP  NSNPS  NPARAM      N        ZSTAT            P        PERMP  NPERM


Adipose_Subcutaneous=$7
Adipose_Visceral_Omentum=$8
Adrenal_Gland=$9
Artery_Aorta=$10
Artery_Coronary=$11
Artery_Tibial=$12
Brain_Amygdala=$13
Brain_Anterior_cingulate_cortex_BA24=$14
Brain_Caudate_basal_ganglia=$15
Brain_Cerebellar_Hemisphere=$16
Brain_Cerebellum=$17
Brain_Cortex=$18
Brain_Frontal_Cortex_BA9=$19
Brain_Hippocampus=$20
Brain_Hypothalamus=$21
Brain_Nucleus_accumbens_basal_ganglia=$22
Brain_Putamen_basal_ganglia=$23
Brain_Spinal_cord_cervical_c_1=$24 ## Changed from Brain_Spinal_cord_cervical_c-1 to Brain_Spinal_cord_cervical_c_1 (hyphon/minus sign is not allowd ina variable name)
Brain_Substantia_nigra=$25
Breast_Mammary_Tissue=$26
Cells_EBV_transformed_lymphocytes=$27 ## Changed from Cells_EBV-transformed_lymphocytes to Cells_EBV_transformed_lymphocytes  (hyphon/minus sign is not allowd ina variable name)
Colon_Sigmoid=$28
Colon_Transverse=$29
Esophagus_Gastroesophageal_Junction=$
Esophagus_Mucosa=$30
Esophagus_Muscularis=$31
Heart_Atrial_Appendage=$32
Heart_Left_Ventricle=$33
Liver=$35
Lung=$35
Minor_Salivary_Gland=$36
Muscle_Skeletal=$37
Nerve_Tibial=$38
Ovary=$39
Pancreas=$40
Pituitary=$41
Prostate=$42
Skin_Not_Sun_Exposed_Suprapubic=$43
Skin_Sun_Exposed_Lower_leg=$44
Small_Intestine_Terminal_Ileum=$45
Spleen=$46
Stomach=$47
Testis=$48
Thyroid=$49
Uterus=$50
Vagina=$51
Whole_Blood=$52


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

declare -a tissues;

Brain_Cerebellum="true";
Adipose_Subcutaneous="true";
Artery_Aorta="true"

# Tissue 1
if [[ "$Adipose_Subcutaneous" = "true" ]];  then
  tissues+=("Adipose_Subcutaneous")
fi

# Tissue 2
if [[ "$Adipose_Visceral_Omentum" = "true" ]];  then
  tissues+=("Adipose_Visceral_Omentum")
fi

# Tissue 3
if [[ "$Adrenal_Gland" = "true" ]];  then
  tissues+=("Adrenal_Gland")
fi

# Tissue 4
if [[ "$Artery_Aorta" = "true" ]];  then
  tissues+=("Artery_Aorta")
fi

# Tissue 5
if [[ "$Artery_Coronary" = "true" ]];  then
  tissues+=("Artery_Coronary")
fi

# Tissue 6
if [[ "$Artery_Tibial" = "true" ]];  then
  tissues+=("Artery_Tibial")
fi

# Tissue 7
if [[ "$Brain_Amygdala" = "true" ]];  then
  tissues+=("Brain_Amygdala")
fi

# Tissue 8
if [[ "$Brain_Anterior_cingulate_cortex_BA24" = "true" ]];  then
  tissues+=("Brain_Anterior_cingulate_cortex_BA24")
fi

# Tissue 9
if [[ "$Brain_Caudate_basal_ganglia" = "true" ]];  then
  tissues+=("Brain_Caudate_basal_ganglia")
fi

# Tissue 10
if [[ "$Brain_Cerebellar_Hemisphere" = "true" ]];  then
  tissues+=("Brain_Cerebellar_Hemisphere")
fi

# Tissue 11
if [[ "$Brain_Cerebellum" = "true" ]];  then
  tissues+=("Brain_Cerebellum")
fi

# Tissue 12
if [[ "$Brain_Cortex" = "true" ]];  then
  tissues+=("Brain_Cortex")
fi

# Tissue 13
if [[ "$Brain_Frontal_Cortex_BA9" = "true" ]];  then
  tissues+=("Brain_Frontal_Cortex_BA9")
fi

# Tissue 14
if [[ "$Brain_Hippocampus" = "true" ]];  then
  tissues+=("Brain_Hippocampus")
fi

# Tissue 15
if [[ "$Brain_Hypothalamus" = "true" ]];  then
  tissues+=("Brain_Hypothalamus")
fi

# Tissue 16
if [[ "$Brain_Nucleus_accumbens_basal_ganglia" = "true" ]];  then
  tissues+=("Brain_Nucleus_accumbens_basal_ganglia")
fi

# Tissue 17
if [[ "$Brain_Putamen_basal_ganglia" = "true" ]];  then
  tissues+=("Brain_Putamen_basal_ganglia")
fi

# Tissue 18
if [[ "$Brain_Spinal_cord_cervical_c_1" = "true" ]];  then
  tissues+=("Brain_Spinal_cord_cervical_c_1")
fi

# Tissue 19
if [[ "$Brain_Substantia_nigra" = "true" ]]; then
  tissues+=("Brain_Substantia_nigra")
fi
# Tissue 20
if [[ "$Breast_Mammary_Tissue" = "true" ]]; then
  tissues+=("Breast_Mammary_Tissue")
fi

# Tissue 21
if [[ "$Cells_EBV_transformed_lymphocytes" = "true" ]]; then
  tissues+=("Cells_EBV_transformed_lymphocytes")
fi

# Tissue 22
if [[ "$Colon_Sigmoid" = "true" ]]; then
  tissues+=("Colon_Sigmoid")
fi

# Tissue 23
if [[ "$Colon_Transverse" = "true" ]]; then
    tissues+=("Colon_Transverse")
fi

# Tissue 24
if [[ "$Esophagus_Gastroesophageal_Junction" = "true" ]]; then
  tissues+=("Esophagus_Gastroesophageal_Junction")
fi

# Tissue 25
if [[ "$Esophagus_Mucosa" = "true" ]]; then
  tissues+=("Esophagus_Mucosa")
fi

# Tissue 26
if [[ "$Esophagus_Muscularis" = "true" ]]; then
  tissues+=("Esophagus_Muscularis")
fi

# Tissue 27
if [[ "$Heart_Atrial_Appendage" = "true" ]]; then
  tissues+=("Heart_Atrial_Appendage")
fi

# Tissue 28
if [[ "$Heart_Left_Ventricle" = "true" ]]; then
  tissues+=("Heart_Left_Ventricle")
fi

# Tissue 29
if [[ "$Liver" = "true" ]]; then
  tissues+=("Liver")
fi

# Tissue 30
if [[ "$Lung" = "true" ]]; then
  tissues+=("Lung")
fi
# Tissue 31

if [[ "$Minor_Salivary_Gland" = "true" ]]; then
  tissues+=("Minor_Salivary_Gland")
fi

# Tissue 32
if [[ "$Muscle_Skeletal" = "true" ]]; then
  tissues+=("Muscle_Skeletal")
fi

# Tissue 33
if [[ "$Nerve_Tibial" = "true" ]]; then
  tissues+=("Nerve_Tibial")
fi

# Tissue 34
if [[ "$Ovary" = "true" ]]; then
  tissues+=("Ovary")
fi

# Tissue 35
if [[ "$Pancreas" = "true" ]]; then
  tissues+=("Pancreas")
fi

# Tissue 36
if [[ "$Pituitary" = "true" ]]; then
  tissues+=("Pituitary")
fi

# Tissue 37
if [[ "$Prostate" = "true" ]]; then
  tissues+=("Prostate")
fi

# Tissue 38
if [[ "$Skin_Not_Sun_Exposed_Suprapubic" = "true" ]]; then
  tissues+=("Skin_Not_Sun_Exposed_Suprapubic")
fi

# Tissue 39
if [[ "$Skin_Sun_Exposed_Lower_leg" = "true" ]]; then
  tissues+=("Skin_Sun_Exposed_Lower_leg")
fi

# Tissue 40
if [[ "$Small_Intestine_Terminal_Ileum" = "true" ]]; then
  tissues+=("Small_Intestine_Terminal_Ileum")
fi

# Tissue 41
if [[ "$Spleen" = "true" ]]; then
  tissues+=("Spleen")
fi

# Tissue 42
if [[ "$Stomach" = "true" ]]; then
  tissues+=("Stomach")
fi

# Tissue 43
if [[ "$Testis" = "true" ]]; then
  tissues+=("Testis")
fi

# Tissue 44
if [[ "$Thyroid" = "true" ]]; then
  tissues+=("Thyroid")
fi

# Tissue 45
if [[ "$Uterus" = "true" ]]; then
  tissues+=("Uterus")
fi

# Tissue 46
if [[ "$Vagina" = "true" ]]; then
  tissues+=("Vagina")
fi

# Tissue 47
if [[ "$Whole_Blood" = "true" ]]; then
  tissues+=("Whole_Blood")
fi


if [[ "${#tissues[@]}" -ge 1  ]]; then
  for tissue in "${tissues[@]}"
  do
    if [[ "$synonym" == "No" ]]; then
    $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonyms=0 \
    --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
    --pval $gwas_summary ncol=N \
    --gene-settings adap-permp=10000 \
    --out ${output_dir}/${output_prefix}.${tissue};
    elif  [[ "$synonym" == "drop" ]]; then
      $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=drop \
      --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
      --pval $gwas_summary ncol=N \
      --gene-settings adap-permp=10000 \
      --out ${output_dir}/${output_prefix}.${tissue};
    elif  [[ "$synonym" == "drop-dup" ]]; then
      $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=drop-dup \
      --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
      --pval $gwas_summary ncol=N \
      --gene-settings adap-permp=10000 \
      --out ${output_dir}/${output_prefix}.${tissue};
    elif  [[ "$synonym" == "skip" ]]; then
      $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=skip \
      --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
      --pval $gwas_summary ncol=N \
      --gene-settings adap-permp=10000 \
      --out ${output_dir}/${output_prefix}.${tissue};
    elif  [[ "$synonym" == "skip-dup" ]]; then
      $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population synonym-dup=skip-dup \
      --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
      --pval $gwas_summary ncol=N \
      --gene-settings adap-permp=10000 \
      --out ${output_dir}/${output_prefix}.${tissue};
    else
      $binary_dir/magma --bfile ${binary_dir}/g1000/g1000_$population  \
      --gene-annot ${binary_dir}/tissues/${tissue}.genes.annot \
      --pval $gwas_summary ncol=N \
      --gene-settings adap-permp=10000 \
      --out ${output_dir}/${output_prefix}.${tissue};
    fi

    Rscript --vanilla ${binary_dir}/Genes.R ${output_dir}/${output_prefix}.${tissue}.genes.out ${binary_dir}/NCBI/NCBI37.3.gene.loc

  done
fi

#### pathway analysis
#### We decided to do pathway analysis in Pascal

#### Reformat gene set Output file by adding genes'
## Oupt file ---> ${output_prefix}.genes.out i.e overwrite the file

Rscript --vanilla ${binary_dir}/Genes.R ${output_dir}/${output_prefix}.genes.out ${binary_dir}/NCBI/NCBI37.3.gene.loc

#### Plots input file
### Tow plots: 1- qq.svg; 2- manhattan.svg
echo "output directory"
echo ${output_dir}
Rscript --vanilla ${binary_dir}/plot_qq_manhattan.R ${GWAS_summary} ${output_dir}
