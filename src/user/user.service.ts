import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);
  constructor(private readonly prisma: PrismaService) {}

  // TODO: Create Function for Register Users
  // TODO: Function for Get All Users
  // TODO: Function for get User by Unique Identifier
  // TODO: Function for get Users by certain requirements
  // TODO: Function for update User
  // TODO: Function for delete User
}
