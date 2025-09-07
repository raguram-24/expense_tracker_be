import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';
import { LoggingExceptionFilter } from './common/filters/logging-exception.filter';
import { HttpAdapterHost } from '@nestjs/core';
import { DetailedLoggingInterceptor } from './common/interceptors/detailed-logging.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // * Apply Interceptors
  app.useGlobalInterceptors(new ResponseInterceptor(), new LoggingInterceptor())
  // ! Only for development as sensitive data may be exposed
  if (process.env.NODE_ENV !== 'production') {
   app.useGlobalInterceptors(new DetailedLoggingInterceptor());
 }
  // * Apply filters
  app.useGlobalFilters(new LoggingExceptionFilter(app.get(HttpAdapterHost)));
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
