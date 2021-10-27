import { Inject, Module, OnModuleInit } from '@nestjs/common';
import { createWorkers } from '../workers/annot.main';
import { GeneSetJobQueue } from './queue/geneset.queue';
import { NatsModule } from '../nats/nats.module';
import { JobCompletedPublisher } from '../nats/publishers/job-completed-publisher';

@Module({
  imports: [NatsModule],
  providers: [GeneSetJobQueue],
  exports: [GeneSetJobQueue],
})
export class QueueModule implements OnModuleInit {
  @Inject(JobCompletedPublisher) jobCompletedPublisher: JobCompletedPublisher;
  async onModuleInit() {
    await createWorkers(this.jobCompletedPublisher);
  }
}
