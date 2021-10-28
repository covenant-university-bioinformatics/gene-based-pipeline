import { Inject, Module, OnModuleInit } from '@nestjs/common';
import { createWorkers } from '../workers/annot.main';
import { GeneBasedJobQueue } from './queue/genebased.queue';
import { NatsModule } from '../nats/nats.module';
import { JobCompletedPublisher } from '../nats/publishers/job-completed-publisher';

@Module({
  imports: [NatsModule],
  providers: [GeneBasedJobQueue],
  exports: [GeneBasedJobQueue],
})
export class QueueModule implements OnModuleInit {
  @Inject(JobCompletedPublisher) jobCompletedPublisher: JobCompletedPublisher;
  async onModuleInit() {
    await createWorkers(this.jobCompletedPublisher);
  }
}
