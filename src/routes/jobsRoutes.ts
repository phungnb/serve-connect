import { Router } from 'express';
import { createJob, listJobApplicants, listJobs } from '../controllers/jobsController';
import { authenticateToken } from '../middleware/authMiddleware';
import { requireRole } from '../middleware/requireRole';
import { asyncHandler } from '../utils/asyncHandler';
import { validateRequest } from '../middleware/validateRequest';
import { createJobSchema } from '../validators/jobValidators';

export const jobsRouter = Router();

jobsRouter.get('/', authenticateToken, asyncHandler(listJobs));
jobsRouter.get('/:jobId/applicants', authenticateToken, requireRole(['CATERER']), asyncHandler(listJobApplicants));
jobsRouter.post('/', authenticateToken, requireRole(['CATERER']), validateRequest(createJobSchema), asyncHandler(createJob));
