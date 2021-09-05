import {
  IsNumberString,
  IsString,
  MaxLength,
  MinLength,
  IsBooleanString,
  IsBoolean,
  IsEnum,
  IsNotEmpty,
} from 'class-validator';
import {Populations, SynonymousSNPS} from "../models/eqtl.model";

export class CreateJobDto {
  @IsString()
  @MinLength(5)
  @MaxLength(20)
  job_name: string;

  @IsNumberString()
  marker_name: string;

  @IsNumberString()
  chromosome: string;

  @IsNumberString()
  position: string;

  @IsNumberString()
  p_value: string;

  @IsNumberString()
  sample_size: string;

  @IsNotEmpty()
  @IsEnum(Populations)
  population: Populations;

  @IsNotEmpty()
  @IsEnum(SynonymousSNPS)
  synonnym: SynonymousSNPS;

  @IsBooleanString()
  Adipose_Subcutaneous: string
  @IsBooleanString()
  Adipose_Visceral_Omentum: string
  @IsBooleanString()
  Adrenal_Gland: string
  @IsBooleanString()
  Artery_Aorta: string
  @IsBooleanString()
  Artery_Coronary: string
  @IsBooleanString()
  Artery_Tibial: string
  @IsBooleanString()
  Brain_Amygdala: string
  @IsBooleanString()
  Brain_Anterior_cingulate_cortex_BA24: string
  @IsBooleanString()
  Brain_Caudate_basal_ganglia: string
  @IsBooleanString()
  Brain_Cerebellar_Hemisphere: string
  @IsBooleanString()
  Brain_Cerebellum: string
  @IsBooleanString()
  Brain_Cortex: string
  @IsBooleanString()
  Brain_Frontal_Cortex_BA9: string
  @IsBooleanString()
  Brain_Hippocampus: string
  @IsBooleanString()
  Brain_Hypothalamus: string
  @IsBooleanString()
  Brain_Nucleus_accumbens_basal_ganglia: string
  @IsBooleanString()
  Brain_Putamen_basal_ganglia: string
  @IsBooleanString()
  Brain_Spinal_cord_cervical_c_1: string
  @IsBooleanString()
  Brain_Substantia_nigra: string
  @IsBooleanString()
  Breast_Mammary_Tissue: string
  @IsBooleanString()
  Cells_EBV_transformed_lymphocytes: string
  @IsBooleanString()
  Colon_Sigmoid: string
  @IsBooleanString()
  Colon_Transverse: string
  @IsBooleanString()
  Esophagus_Gastroesophageal_Junction: string
  @IsBooleanString()
  Esophagus_Mucosa: string
  @IsBooleanString()
  Esophagus_Muscularis: string
  @IsBooleanString()
  Heart_Atrial_Appendage: string
  @IsBooleanString()
  Heart_Left_Ventricle: string
  @IsBooleanString()
  Liver: string
  @IsBooleanString()
  Lung: string
  @IsBooleanString()
  Minor_Salivary_Gland: string
  @IsBooleanString()
  Muscle_Skeletal: string
  @IsBooleanString()
  Nerve_Tibial: string
  @IsBooleanString()
  Ovary: string
  @IsBooleanString()
  Pancreas: string
  @IsBooleanString()
  Pituitary: string
  @IsBooleanString()
  Prostate: string
  @IsBooleanString()
  Skin_Not_Sun_Exposed_Suprapubic: string
  @IsBooleanString()
  Skin_Sun_Exposed_Lower_leg: string
  @IsBooleanString()
  Small_Intestine_Terminal_Ileum: string
  @IsBooleanString()
  Spleen: string
  @IsBooleanString()
  Stomach: string
  @IsBooleanString()
  Testis: string
  @IsBooleanString()
  Thyroid: string
  @IsBooleanString()
  Uterus: string
  @IsBooleanString()
  Vagina: string
  @IsBooleanString()
  Whole_Blood: string
}
