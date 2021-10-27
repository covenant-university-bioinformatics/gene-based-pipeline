import { Global, Module } from '@nestjs/common';
import { JobsGenesetService } from './services/jobs.geneset.service';
import { JobsGenesetController } from './controllers/jobs.geneset.controller';
import { QueueModule } from '../jobqueue/queue.module';

@Global()
@Module({
  imports: [
    QueueModule,
    // AuthModule,
    // NatsModule,
  ],
  controllers: [JobsGenesetController],
  providers: [JobsGenesetService],
  exports: [],
})
export class JobsModule {}
