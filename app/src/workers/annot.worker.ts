import { SandboxedJob } from 'bullmq';
import * as fs from 'fs';
import {
  EqtlJobsDoc,
  JobStatus,
  EqtlJobsModel,
} from '../jobs/models/geneset.jobs.model';
import {
  EqtlDoc,
  EqtlModel,
} from '../jobs/models/geneset.model';
import { spawn, spawnSync } from 'child_process';
import connectDB from '../mongoose';

import { fileOrPathExists } from '../utils/utilityfunctions';
function sleep(ms) {
  console.log('sleeping');
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getJobParameters(parameters: EqtlDoc) {
  return [
    String(parameters.population),
    String(parameters.synonnym),
    String(parameters.Adipose_Subcutaneous),
    String(parameters.Adipose_Visceral_Omentum),
    String(parameters.Adrenal_Gland),
    String(parameters.Artery_Aorta),
    String(parameters.Artery_Coronary),
    String(parameters.Artery_Tibial),
    String(parameters.Brain_Amygdala),
    String(parameters.Brain_Anterior_cingulate_cortex_BA24),
    String(parameters.Brain_Caudate_basal_ganglia),
    String(parameters.Brain_Cerebellar_Hemisphere),
    String(parameters.Brain_Cerebellum),
    String(parameters.Brain_Cortex),
    String(parameters.Brain_Frontal_Cortex_BA9),
    String(parameters.Brain_Hippocampus),
    String(parameters.Brain_Hypothalamus),
    String(parameters.Brain_Nucleus_accumbens_basal_ganglia),
    String(parameters.Brain_Putamen_basal_ganglia),
    String(parameters.Brain_Spinal_cord_cervical_c_1), //changed
    String(parameters.Brain_Substantia_nigra),
    String(parameters.Breast_Mammary_Tissue),
    String(parameters.Cells_EBV_transformed_lymphocytes), //changed
    String(parameters.Colon_Sigmoid),
    String(parameters.Colon_Transverse),
    String(parameters.Esophagus_Gastroesophageal_Junction),
    String(parameters.Esophagus_Mucosa),
    String(parameters.Esophagus_Muscularis),
    String(parameters.Heart_Atrial_Appendage),
    String(parameters.Heart_Left_Ventricle),
    String(parameters.Liver),
    String(parameters.Lung),
    String(parameters.Minor_Salivary_Gland),
    String(parameters.Muscle_Skeletal),
    String(parameters.Nerve_Tibial),
    String(parameters.Ovary),
    String(parameters.Pancreas),
    String(parameters.Pituitary),
    String(parameters.Prostate),
    String(parameters.Skin_Not_Sun_Exposed_Suprapubic),
    String(parameters.Skin_Sun_Exposed_Lower_leg),
    String(parameters.Small_Intestine_Terminal_Ileum),
    String(parameters.Spleen),
    String(parameters.Stomach),
    String(parameters.Testis),
    String(parameters.Thyroid),
    String(parameters.Uterus),
    String(parameters.Vagina),
    String(parameters.Whole_Blood),
  ];
}

export default async (job: SandboxedJob) => {
  //executed for each job
  console.log(
    'Worker ' +
      ' processing job ' +
      JSON.stringify(job.data.jobId) +
      ' Job name: ' +
      JSON.stringify(job.data.jobName),
  );

  await connectDB();
  await sleep(2000);

  //fetch job parameters from database
  const parameters = await EqtlModel.findOne({
    job: job.data.jobId,
  }).exec();
  const jobParams = await EqtlJobsModel.findById(job.data.jobId).exec();

  //assemble job parameters
  const pathToInputFile = `${jobParams.inputFile}`;
  const pathToOutputDir = `/pv/analysis/${job.data.jobUID}/eqtl/output`;
  const jobParameters = getJobParameters(parameters);
  jobParameters.unshift(pathToInputFile, pathToOutputDir);
  // console.log(jobParameters);
  console.log(jobParameters);
  //make output directory
  fs.mkdirSync(pathToOutputDir, { recursive: true });

  // save in mongo database
  await EqtlJobsModel.findByIdAndUpdate(
    job.data.jobId,
    {
      status: JobStatus.RUNNING,
    },
    { new: true },
  );

  //spawn process
  const start = Date.now();
  const jobSpawn = spawnSync(
    './pipeline_scripts/eMAGMA.sh',
    jobParameters,
    // { detached: true },
  );

  console.log('Spawn command log');
  console.log(jobSpawn?.stdout?.toString());
  console.log('=====================================');
  console.log('Spawn error log');
  const error_msg = jobSpawn?.stderr?.toString();
  console.log(error_msg);

  const annot = await fileOrPathExists(
    `${pathToOutputDir}/annotation_output.hg19_multianno_full.tsv`,
  );

  let disgenet = true;

  if (jobParams.disgenet) {
    disgenet = false;
    disgenet = await fileOrPathExists(`${pathToOutputDir}/disgenet.txt`);
  }

  if (annot && disgenet) {
    console.log(`${job?.data?.jobName} spawn done!`);
    return true;
  } else {
    throw new Error(error_msg || 'Job failed to successfully complete');
  }

  return true;
};
