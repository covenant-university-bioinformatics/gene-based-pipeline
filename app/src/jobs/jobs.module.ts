import { Global, Module } from '@nestjs/common';
import { JobsGeneBasedService } from './services/jobs.genebased.service';
import { JobsGeneBasedController } from './controllers/jobs.genebased.controller';
import { QueueModule } from '../jobqueue/queue.module';

@Global()
@Module({
  imports: [
    QueueModule,
    // AuthModule,
    // NatsModule,
  ],
  controllers: [JobsGeneBasedController],
  providers: [JobsGeneBasedService],
  exports: [],
})
export class JobsModule {}
