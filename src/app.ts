import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import { corsOrigin } from './config/env';
import { authRouter } from './routes/authRoutes';
import { jobsRouter } from './routes/jobsRoutes';
import { applicationsRouter } from './routes/applicationsRoutes';
import { errorHandler } from './middleware/errorHandler';
import { notFoundHandler } from './middleware/notFoundHandler';
import adminRoutes from './routes/adminRoutes';
import { profileRouter } from './routes/profileRoutes';

export function createApp() {
  const app = express();

  app.use(helmet());
  app.use(cors({ origin: corsOrigin, credentials: true }));
  app.use(express.json({ limit: '100kb' }));

  app.get('/health', (_req, res) => {
    res.status(200).json({ ok: true });
  });

  app.use('/api/auth', authRouter);
  app.use('/api/profile', profileRouter);
  app.use('/api/jobs', jobsRouter);
  app.use('/api/admin', adminRoutes);
  app.use('/api/applications', applicationsRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
