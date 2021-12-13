import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Inject,
  Injectable, InternalServerErrorException, NotFoundException,
} from '@nestjs/common';
import { CreateJobDto } from '../dto/create-job.dto';
import {
  GeneBasedJobsDoc,
  GeneBasedJobsModel,
  JobStatus,
} from '../models/genebased.jobs.model';
import { GeneBasedModel } from '../models/genebased.model';
import { GeneBasedJobQueue } from '../../jobqueue/queue/genebased.queue';
import { UserDoc } from '../../auth/models/user.model';
import { GetJobsDto } from '../dto/getjobs.dto';
import * as fs from 'fs';
import { v4 as uuidv4 } from 'uuid';
import {
  deleteFileorFolder,
  fileOrPathExists, findAllJobs,
  removeManyUserJobs,
  removeUserJob,
  writeGeneBasedFile
} from "@cubrepgwas/pgwascommon";

//production
const testPath = '/local/datasets/pgwas_test_files/magma/emagma_test.txt';
//development
// const testPath = '/local/datasets/data/magma/emagma_test.txt';

@Injectable()
export class JobsGeneBasedService {
  constructor(
    @Inject(GeneBasedJobQueue)
    private jobQueue: GeneBasedJobQueue,
  ) {}

  async create(
    createJobDto: CreateJobDto,
    file: Express.Multer.File,
    user?: UserDoc,
  ) {
    if (createJobDto.useTest === 'false') {
      if (!file) {
        throw new BadRequestException('Please upload a file');
      }

      if (file.mimetype !== 'text/plain') {
        throw new BadRequestException('Please upload a text file');
      }
    }

    if (!user && !createJobDto.email) {
      throw new BadRequestException(
          'Job cannot be null, check job parameters, and try again',
      );
    }

    if (user && createJobDto.email) {
      throw new BadRequestException('User signed in, no need for email');
    }

    const numberColumns = [
      'marker_name',
      'chromosome',
      'position',
      'p_value',
      'sample_size',
    ];

    //change number columns to integers
    const columns = numberColumns.map((column) => {
      return parseInt(createJobDto[column], 10);
    });

    //check if there are wrong column numbers
    const wrongColumn = columns.some((value) => value < 1 || value > 15);

    if (wrongColumn) {
      throw new BadRequestException('Column numbers must be between 0 and 15');
    }
    //check if there are duplicate columns
    const duplicates = new Set(columns).size !== columns.length;

    if (duplicates) {
      throw new BadRequestException('Column numbers must not have duplicates');
    }

    //create jobUID
    const jobUID = uuidv4();

    //create folder with job uid and create input folder in job uid folder
    const value = await fileOrPathExists(`/pv/analysis/${jobUID}`);

    if (!value) {
      fs.mkdirSync(`/pv/analysis/${jobUID}/input`, { recursive: true });
    } else {
      throw new InternalServerErrorException();
    }

    let filename;

    if (createJobDto.useTest === 'false') {
      filename = `/pv/analysis/${jobUID}/input/${file.filename}`;
    } else {
      filename = `/pv/analysis/${jobUID}/input/test.txt`;
    }

    const session = await GeneBasedJobsModel.startSession();
    const sessionTest = await GeneBasedModel.startSession();
    session.startTransaction();
    sessionTest.startTransaction();

    try {
      // console.log('DTO: ', createJobDto);
      const opts = { session };
      const optsTest = { session: sessionTest };

      const filepath = createJobDto.useTest === 'true' ? testPath : file.path;

      //write the exact columns needed by the analysis
      const totalLines = writeGeneBasedFile(filepath, filename, {
        marker_name: parseInt(createJobDto.marker_name, 10) - 1,
        chr: parseInt(createJobDto.chromosome, 10) - 1,
        p: parseInt(createJobDto.p_value, 10) - 1,
        n: parseInt(createJobDto.sample_size, 10) - 1,
        pos: parseInt(createJobDto.position, 10) - 1,
      });

      if (createJobDto.useTest === 'false') {
        deleteFileorFolder(file.path).then(() => {
          // console.log('deleted');
        });
      }

      const longJob = totalLines > 100000;

      let newJob;

      //save job parameters, folder path, filename in database
      if(user){
        newJob = await GeneBasedJobsModel.build({
          job_name: createJobDto.job_name,
          jobUID,
          inputFile: filename,
          status: JobStatus.QUEUED,
          user: user.id,
          longJob,
        });
      }

      if(createJobDto.email){
        newJob = await GeneBasedJobsModel.build({
          job_name: createJobDto.job_name,
          jobUID,
          inputFile: filename,
          status: JobStatus.QUEUED,
          email: createJobDto.email,
          longJob,
        });
      }

      if (!newJob) {
        throw new BadRequestException(
            'Job cannot be null, check job parameters',
        );
      }

      //let the models be created per specific analysis
      const genebased = await GeneBasedModel.build({
        ...createJobDto,
        job: newJob.id,
      });

      await genebased.save(optsTest);
      await newJob.save(opts);

      //add job to queue
      if (user) {
        await this.jobQueue.addJob({
          jobId: newJob.id,
          jobName: newJob.job_name,
          jobUID: newJob.jobUID,
          username: user.username,
          email: user.email,
          noAuth: false,
        });
      }

      if (createJobDto.email) {
        await this.jobQueue.addJob({
          jobId: newJob.id,
          jobName: newJob.job_name,
          jobUID: newJob.jobUID,
          username: 'User',
          email: createJobDto.email,
          noAuth: true,
        });
      }

      await session.commitTransaction();
      await sessionTest.commitTransaction();
      return {
        success: true,
        jobId: newJob.id,
      };
    } catch (e) {
      if (e.code === 11000) {
        throw new ConflictException('Duplicate job name not allowed');
      }
      await session.abortTransaction();
      await sessionTest.abortTransaction();
      deleteFileorFolder(`/pv/analysis/${jobUID}`).then(() => {
        // console.log('deleted');
      });
      throw new BadRequestException(e.message);
    } finally {
      session.endSession();
      sessionTest.endSession();
    }
  }


  // {
  //   $lookup: {
  //     from: 'annotations',
  //     localField: '_id',
  //     foreignField: 'job',
  //     as: 'annot',
  //   },
  // },
  async findAll(getJobsDto: GetJobsDto, user: UserDoc) {
    return await findAllJobs(getJobsDto, user, GeneBasedJobsModel);
  }

  async getJobByID(id: string, user: UserDoc) {
    const job = await GeneBasedJobsModel.findById(id)
        .populate('genebased_params')
        .populate('user')
        .exec();

    if (!job) {
      throw new NotFoundException();
    }

    if (job?.user?.username !== user.username) {
      throw new ForbiddenException('Access not allowed');
    }

    return job;
  }

  async getJobByIDNoAuth(id: string) {
    const job = await GeneBasedJobsModel.findById(id)
        .populate('genebased_params')
        .populate('user')
        .exec();

    if (!job) {
      throw new NotFoundException();
    }

    if (job?.user?.username) {
      throw new ForbiddenException('Access not allowed');
    }

    return job;
  }

  async removeJob(id: string, user: UserDoc) {
    const job = await this.getJobByID(id, user);

    return await removeUserJob(id, job);
  }

  async removeJobNoAuth(id: string) {
    const job = await this.getJobByIDNoAuth(id);

    return await removeUserJob(id, job);
  }

  async deleteManyJobs(user: UserDoc) {
    return await removeManyUserJobs(user, GeneBasedJobsModel);
  }
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
