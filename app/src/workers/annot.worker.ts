import { SandboxedJob } from 'bullmq';
import * as fs from 'fs';
import {
  GeneBasedJobsDoc,
  JobStatus,
  GeneBasedJobsModel,
} from '../jobs/models/genebased.jobs.model';
import { GeneBasedDoc, GeneBasedModel } from '../jobs/models/genebased.model';
import { spawn, spawnSync } from 'child_process';
import connectDB, { closeDB } from '../mongoose';
import {
  deleteFileorFolder,
  fileOrPathExists,
  writeGeneBasedFile,
} from '@cubrepgwas/pgwascommon';

function sleep(ms) {
  console.log('sleeping');
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getJobParameters(parameters: GeneBasedDoc) {
  return [
    String(parameters.population),
    String(parameters.synonym),
    String(parameters.up_window),
    String(parameters.down_window),
    String(parameters.tissue),
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
  const parameters = await GeneBasedModel.findOne({
    job: job.data.jobId,
  }).exec();
  const jobParams = await GeneBasedJobsModel.findById(job.data.jobId).exec();

  //create input file and folder
  let filename;

  //extract file name
  const name = jobParams.inputFile.split(/(\\|\/)/g).pop();

  if (parameters.useTest === false) {
    filename = `/pv/analysis/${jobParams.jobUID}/input/${name}`;
  } else {
    filename = `/pv/analysis/${jobParams.jobUID}/input/test.txt`;
  }

  //write the exact columns needed by the analysis
  writeGeneBasedFile(jobParams.inputFile, filename, {
    marker_name: parameters.marker_name - 1,
    chr: parameters.chromosome - 1,
    p: parameters.p_value - 1,
    n: parameters.sample_size - 1,
    pos: parameters.position - 1,
  });

  if (parameters.useTest === false) {
    deleteFileorFolder(jobParams.inputFile).then(() => {
      // console.log('deleted');
    });
  }

  //assemble job parameters
  const pathToInputFile = filename;
  const pathToOutputDir = `/pv/analysis/${job.data.jobUID}/genebased/output`;
  const jobParameters = getJobParameters(parameters);
  jobParameters.unshift(pathToInputFile, pathToOutputDir);
  // console.log(jobParameters);
  console.log(jobParameters);
  //make output directory
  fs.mkdirSync(pathToOutputDir, { recursive: true });

  // save in mongo database
  await GeneBasedJobsModel.findByIdAndUpdate(
    job.data.jobId,
    {
      status: JobStatus.RUNNING,
    },
    { new: true },
  );

  await sleep(3000);
  //spawn process
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
  // console.log(error_msg);

  const genes_out = await fileOrPathExists(
    `${pathToOutputDir}/Gene_set.genes.out`,
  );

  const manhattan_plot = await fileOrPathExists(
    `${pathToOutputDir}/manhattan.png`,
  );

  const qq_plot = await fileOrPathExists(`${pathToOutputDir}/qq.png`);

  closeDB();
  let tissues = true;

  if (parameters.tissue !== '') {
    tissues = false;
    tissues = await fileOrPathExists(
      `${pathToOutputDir}/Gene_set.${parameters.tissue}.genes.out`,
    );
  }
  console.log(genes_out, tissues, manhattan_plot, qq_plot);

  if (genes_out && tissues && manhattan_plot && qq_plot) {
    console.log(`${job?.data?.jobName} spawn done!`);
    return true;
  } else {
    throw new Error(error_msg || 'Job failed to successfully complete');
    // throw new Error('Job failed to successfully complete');
  }

  return true;
};
