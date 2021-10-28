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
interface GeneBasedAttrs {
  job: string;
  population: Populations;
  synonym: SynonymousSNPS;
  up_window: string;
  down_window: string;
  tissue: string;
}

// An interface that describes the extra properties that a ticket model has
//collection level methods
interface GeneBasedModel extends mongoose.Model<GeneBasedDoc> {
  build(attrs: GeneBasedAttrs): GeneBasedDoc;
}

//An interface that describes a properties that a document has
export interface GeneBasedDoc extends mongoose.Document {
  id: string;
  version: number;
  population: Populations;
  synonym: SynonymousSNPS;
  up_window: string;
  down_window: string;
  tissue: string;
}

const GeneBasedSchema = new mongoose.Schema<GeneBasedDoc, GeneBasedModel>(
  {
    population: {
      type: String,
      trim: true,
    },
    synonym: {
      type: String,
      trim: true,
    },
    up_window: {
      type: String,
      trim: true,
    },
    down_window: {
      type: String,
      trim: true,
    },
    tissue: {
      type: String,
      trim: true,
    },
    job: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'GeneBasedJob',
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
GeneBasedSchema.set('versionKey', 'version');

//collection level methods
GeneBasedSchema.statics.build = (attrs: GeneBasedAttrs) => {
  return new GeneBasedModel(attrs);
};

//create mongoose model
const GeneBasedModel = mongoose.model<GeneBasedDoc, GeneBasedModel>(
  'GeneBased',
  GeneBasedSchema,
  'genebaseds',
);

export { GeneBasedModel };
