import * as mongoose from 'mongoose';

export enum Populations {
  AFR = 'afr',
  AMR = 'amr',
  EUR = 'eur',
  EAS = 'eas',
  SAS = 'sas',
}

export enum SynonymousSNPS {
  NO = 'No',
  DROP = 'drop',
  DROP_DUP = 'drop-dup',
  SKIP = 'skip',
  SKIP_DUP = 'skip_dup',
}

//Interface that describe the properties that are required to create a new job
interface GeneSetAttrs {
  job: string;
  population: Populations;
  synonnym: SynonymousSNPS;
  Adipose_Subcutaneous: string;
  Adipose_Visceral_Omentum: string;
  Adrenal_Gland: string;
  Artery_Aorta: string;
  Artery_Coronary: string;
  Artery_Tibial: string;
  Brain_Amygdala: string;
  Brain_Anterior_cingulate_cortex_BA24: string;
  Brain_Caudate_basal_ganglia: string;
  Brain_Cerebellar_Hemisphere: string;
  Brain_Cerebellum: string;
  Brain_Cortex: string;
  Brain_Frontal_Cortex_BA9: string;
  Brain_Hippocampus: string;
  Brain_Hypothalamus: string;
  Brain_Nucleus_accumbens_basal_ganglia: string;
  Brain_Putamen_basal_ganglia: string;
  Brain_Spinal_cord_cervical_c_1: string; //changed
  Brain_Substantia_nigra: string;
  Breast_Mammary_Tissue: string;
  Cells_EBV_transformed_lymphocytes: string; //changed
  Colon_Sigmoid: string;
  Colon_Transverse: string;
  Esophagus_Gastroesophageal_Junction: string;
  Esophagus_Mucosa: string;
  Esophagus_Muscularis: string;
  Heart_Atrial_Appendage: string;
  Heart_Left_Ventricle: string;
  Liver: string;
  Lung: string;
  Minor_Salivary_Gland: string;
  Muscle_Skeletal: string;
  Nerve_Tibial: string;
  Ovary: string;
  Pancreas: string;
  Pituitary: string;
  Prostate: string;
  Skin_Not_Sun_Exposed_Suprapubic: string;
  Skin_Sun_Exposed_Lower_leg: string;
  Small_Intestine_Terminal_Ileum: string;
  Spleen: string;
  Stomach: string;
  Testis: string;
  Thyroid: string;
  Uterus: string;
  Vagina: string;
  Whole_Blood: string;
}

// An interface that describes the extra properties that a ticket model has
//collection level methods
interface GeneSetModel extends mongoose.Model<GeneSetDoc> {
  build(attrs: GeneSetAttrs): GeneSetDoc;
}

//An interface that describes a properties that a document has
export interface GeneSetDoc extends mongoose.Document {
  id: string;
  version: number;
  population: Populations;
  synonnym: SynonymousSNPS;
  Adipose_Subcutaneous: boolean;
  Adipose_Visceral_Omentum: boolean;
  Adrenal_Gland: boolean;
  Artery_Aorta: boolean;
  Artery_Coronary: boolean;
  Artery_Tibial: boolean;
  Brain_Amygdala: boolean;
  Brain_Anterior_cingulate_cortex_BA24: boolean;
  Brain_Caudate_basal_ganglia: boolean;
  Brain_Cerebellar_Hemisphere: boolean;
  Brain_Cerebellum: boolean;
  Brain_Cortex: boolean;
  Brain_Frontal_Cortex_BA9: boolean;
  Brain_Hippocampus: boolean;
  Brain_Hypothalamus: boolean;
  Brain_Nucleus_accumbens_basal_ganglia: boolean;
  Brain_Putamen_basal_ganglia: boolean;
  Brain_Spinal_cord_cervical_c_1: boolean; //changed
  Brain_Substantia_nigra: boolean;
  Breast_Mammary_Tissue: boolean;
  Cells_EBV_transformed_lymphocytes: boolean; //changed
  Colon_Sigmoid: boolean;
  Colon_Transverse: boolean;
  Esophagus_Gastroesophageal_Junction: boolean;
  Esophagus_Mucosa: boolean;
  Esophagus_Muscularis: boolean;
  Heart_Atrial_Appendage: boolean;
  Heart_Left_Ventricle: boolean;
  Liver: boolean;
  Lung: boolean;
  Minor_Salivary_Gland: boolean;
  Muscle_Skeletal: boolean;
  Nerve_Tibial: boolean;
  Ovary: boolean;
  Pancreas: boolean;
  Pituitary: boolean;
  Prostate: boolean;
  Skin_Not_Sun_Exposed_Suprapubic: boolean;
  Skin_Sun_Exposed_Lower_leg: boolean;
  Small_Intestine_Terminal_Ileum: boolean;
  Spleen: boolean;
  Stomach: boolean;
  Testis: boolean;
  Thyroid: boolean;
  Uterus: boolean;
  Vagina: boolean;
  Whole_Blood: boolean;
}

const GeneSetSchema = new mongoose.Schema<GeneSetDoc, GeneSetModel>(
  {
      Adipose_Subcutaneous: {
          type: Boolean,
          default: false,
      },
      Adipose_Visceral_Omentum: {
          type: Boolean,
          default: false,
      },
      Adrenal_Gland: {
          type: Boolean,
          default: false,
      },
      Artery_Aorta: {
          type: Boolean,
          default: false,
      },
      Artery_Coronary: {
          type: Boolean,
          default: false,
      },
      Artery_Tibial: {
          type: Boolean,
          default: false,
      },
      Brain_Amygdala: {
          type: Boolean,
          default: false,
      },
      Brain_Anterior_cingulate_cortex_BA24: {
          type: Boolean,
          default: false,
      },
      Brain_Caudate_basal_ganglia: {
          type: Boolean,
          default: false,
      },
      Brain_Cerebellar_Hemisphere: {
          type: Boolean,
          default: false,
      },
      Brain_Cerebellum: {
          type: Boolean,
          default: false,
      },
      Brain_Cortex: {
          type: Boolean,
          default: false,
      },
      Brain_Frontal_Cortex_BA9: {
          type: Boolean,
          default: false,
      },
      Brain_Hippocampus: {
          type: Boolean,
          default: false,
      },
      Brain_Hypothalamus: {
          type: Boolean,
          default: false,
      },
      Brain_Nucleus_accumbens_basal_ganglia: {
          type: Boolean,
          default: false,
      },
      Brain_Putamen_basal_ganglia: {
          type: Boolean,
          default: false,
      },
      Brain_Spinal_cord_cervical_c_1: {
          type: Boolean,
          default: false,
      },
      Brain_Substantia_nigra: {
          type: Boolean,
          default: false,
      },
      Breast_Mammary_Tissue: {
          type: Boolean,
          default: false,
      },
      Cells_EBV_transformed_lymphocytes: {
          type: Boolean,
          default: false,
      },
      Colon_Sigmoid: {
          type: Boolean,
          default: false,
      },
      Colon_Transverse: {
          type: Boolean,
          default: false,
      },
      Esophagus_Gastroesophageal_Junction: {
          type: Boolean,
          default: false,
      },
      Esophagus_Mucosa: {
          type: Boolean,
          default: false,
      },
      Esophagus_Muscularis: {
          type: Boolean,
          default: false,
      },
      Heart_Atrial_Appendage: {
          type: Boolean,
          default: false,
      },
      Heart_Left_Ventricle: {
          type: Boolean,
          default: false,
      },
      Liver: {
          type: Boolean,
          default: false,
      },
      Lung: {
          type: Boolean,
          default: false,
      },
      Minor_Salivary_Gland: {
          type: Boolean,
          default: false,
      },
      Muscle_Skeletal: {
          type: Boolean,
          default: false,
      },
      Nerve_Tibial: {
          type: Boolean,
          default: false,
      },
      Ovary: {
          type: Boolean,
          default: false,
      },
      Pancreas: {
          type: Boolean,
          default: false,
      },
      Pituitary: {
          type: Boolean,
          default: false,
      },
      Prostate: {
          type: Boolean,
          default: false,
      },
      Skin_Not_Sun_Exposed_Suprapubic: {
          type: Boolean,
          default: false,
      },
      Skin_Sun_Exposed_Lower_leg: {
          type: Boolean,
          default: false,
      },
      Small_Intestine_Terminal_Ileum: {
          type: Boolean,
          default: false,
      },
      Spleen: {
          type: Boolean,
          default: false,
      },
      Stomach: {
          type: Boolean,
          default: false,
      },
      Testis: {
          type: Boolean,
          default: false,
      },
      Thyroid: {
          type: Boolean,
          default: false,
      },
      Uterus: {
          type: Boolean,
          default: false,
      },
      Vagina: {
          type: Boolean,
          default: false,
      },
      Whole_Blood: {
          type: Boolean,
          default: false,
      },
    job: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'GeneSetJob',
      required: true,
    },
    version: {
      type: Number,
    },
  },
  {
    timestamps: true,
    versionKey: 'version',
    toJSON: {
      transform(doc, ret) {
        ret.id = ret._id;
        // delete ret._id;
        // delete ret.__v;
      },
    },
  },
);

//increments version when document updates
GeneSetSchema.set('versionKey', 'version');

//collection level methods
GeneSetSchema.statics.build = (attrs: GeneSetAttrs) => {
  return new GeneSetModel(attrs);
};

//create mongoose model
const GeneSetModel = mongoose.model<GeneSetDoc, GeneSetModel>(
  'GeneSet',
  GeneSetSchema,
  'genesets',
);

export { GeneSetModel };
