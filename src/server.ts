import { createApp } from './app';
import { env } from './config/env';
import { closePool } from './config/db';

const app = createApp();

const server = app.listen(env.PORT, () => {
  console.log(`ServeConnect API listening on port ${env.PORT}`);
});

async function shutdown(signal: string) {
  console.log(`${signal} received, shutting down...`);
  server.close(async () => {
    await closePool();
    process.exit(0);
  });
}

process.on('SIGINT', () => {
  void shutdown('SIGINT');
});

process.on('SIGTERM', () => {
  void shutdown('SIGTERM');
});
