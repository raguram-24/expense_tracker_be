import { Controller, Get, Logger, UseFilters } from '@nestjs/common';
import { CustomResponseFilter } from 'src/common/filters/custom-responce.filter';

@Controller('user')
@UseFilters(CustomResponseFilter)
export class UserController {
    private readonly logger = new Logger(UserController.name)

    @Get()
    async findAll(){
        return 'Hello World'
    }
}
