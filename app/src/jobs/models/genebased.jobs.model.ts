import * as mongoose from 'mongoose';
import { UserDoc } from '../../auth/models/user.model';
import { GeneBasedDoc } from './genebased.model';

export enum JobStatus {
  COMPLETED = 'completed',
  RUNNING = 'running',
  FAILED = 'failed',
  ABORTED = 'aborted',
  NOTSTARTED = 'not-started',
  QUEUED = 'queued',
}

//Interface that describe the properties that are required to create a new job
interface JobsAttrs {
  jobUID: string;
  job_name: string;
  status: JobStatus;
  user?: string;
  email?: string;
  inputFile: string;
  longJob: boolean;
}

// An interface that describes the extra properties that a model has
//collection level methods
interface JobsModel extends mongoose.Model<GeneBasedJobsDoc> {
  build(attrs: JobsAttrs): GeneBasedJobsDoc;
}

//An interface that describes a properties that a document has
export interface GeneBasedJobsDoc extends mongoose.Document {
  id: string;
  jobUID: string;
  job_name: string;
  inputFile: string;
  status: JobStatus;
  user?: UserDoc;
  email?: string;
  gene_based_genes_out: string;
  gene_based_tissue_genes_out: string;
  manhattan_plot: string;
  qq_plot: string;
  failed_reason: string;
  longJob: boolean;
  genebased_params: GeneBasedDoc;
  version: number;
  completionTime: Date;
}

const GeneBasedJobSchema = new mongoose.Schema<GeneBasedJobsDoc, JobsModel>(
  {
    jobUID: {
      type: String,
      required: [true, 'Please add a Job UID'],
      unique: true,
      trim: true,
    },

    job_name: {
      type: String,
      required: [true, 'Please add a name'],
    },

    inputFile: {
      type: String,
      required: [true, 'Please add a input filename'],
      unique: true,
      trim: true,
    },

    gene_based_genes_out: {
      type: String,
      trim: true,
    },

    gene_based_tissue_genes_out: {
      type: String,
      trim: true,
    },

    manhattan_plot: {
      type: String,
      trim: true,
    },

    qq_plot: {
      type: String,
      trim: true,
    },

    failed_reason: {
      type: String,
      trim: true,
    },

    status: {
      type: String,
      enum: [
        JobStatus.COMPLETED,
        JobStatus.NOTSTARTED,
        JobStatus.RUNNING,
        JobStatus.FAILED,
        JobStatus.ABORTED,
        JobStatus.QUEUED,
      ],
      default: JobStatus.NOTSTARTED,
    },
    longJob: {
      type: Boolean,
      default: false,
    },
    completionTime: {
      type: Date,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    email: {
      type: String,
      trim: true,
    },
    version: {
      type: Number,
    },
  },
  {
    timestamps: true,
    versionKey: 'version',
    toObject: { virtuals: true },
    toJSON: {
      virtuals: true,
      transform(doc, ret) {
        ret.id = ret._id;
        // delete ret._id;
        // delete ret.__v;
      },
    },
  },
);

//increments version when document updates
// jobsSchema.set("versionKey", "version");

//collection level methods
GeneBasedJobSchema.statics.build = (attrs: JobsAttrs) => {
  return new GeneBasedJobsModel(attrs);
};

//Cascade delete main job parameters when job is deleted
GeneBasedJobSchema.pre('remove', async function (next) {
  console.log('Job parameters being removed!');
  await this.model('GeneBased').deleteMany({
    job: this.id,
  });
  next();
});

//reverse populate jobs with main job parameters
GeneBasedJobSchema.virtual('genebased_params', {
  ref: 'GeneBased',
  localField: '_id',
  foreignField: 'job',
  required: true,
  justOne: true,
});

GeneBasedJobSchema.set('versionKey', 'version');

//create mongoose model
const GeneBasedJobsModel = mongoose.model<GeneBasedJobsDoc, JobsModel>(
  'GeneBasedJob',
  GeneBasedJobSchema,
  'genebasedjobs',
);

export { GeneBasedJobsModel };
