import {
  IsNumberString,
  IsString,
  MaxLength,
  MinLength,
  IsEnum,
  IsNotEmpty,
} from 'class-validator';
import {Populations, SynonymousSNPS} from "../models/genebased.model";

export class CreateJobDto {
  @IsString()
  @MinLength(5)
  @MaxLength(20)
  job_name: string;

  @IsNumberString()
  marker_name: string;

  @IsNumberString()
  chromosome: string;

  @IsNumberString()
  position: string;

  @IsNumberString()
  p_value: string;

  @IsNumberString()
  sample_size: string;

  @IsNotEmpty()
  @IsEnum(Populations)
  population: Populations;

  @IsNotEmpty()
  @IsEnum(SynonymousSNPS)
  synonym: SynonymousSNPS;

  @IsNumberString()
  up_window: string;

  @IsNumberString()
  down_window: string;

  @IsString()
  tissue: string;
}
