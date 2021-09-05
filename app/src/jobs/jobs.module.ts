import { Global, Module } from '@nestjs/common';
import { JobsEqtlService } from './services/jobs.eqtl.service';
import { JobsEqtlController } from './controllers/jobs.eqtl.controller';
import { QueueModule } from '../jobqueue/queue.module';

@Global()
@Module({
  imports: [
    QueueModule,
    // AuthModule,
    // NatsModule,
  ],
  controllers: [JobsEqtlController],
  providers: [JobsEqtlService],
  exports: [],
})
export class JobsModule {}
