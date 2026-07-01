import { Router } from 'express';
import { applyToJob, updateApplicationStatus } from '../controllers/applicationsController';
import { authMiddleware } from '../middleware/authMiddleware';
import { requireRole } from '../middleware/requireRole';
import { asyncHandler } from '../utils/asyncHandler';
import { validateRequest } from '../middleware/validateRequest';
import { applySchema, updateApplicationStatusSchema } from '../validators/applicationValidators';

export const applicationsRouter = Router();

applicationsRouter.post('/apply', authMiddleware, requireRole(['STUDENT']), validateRequest(applySchema), asyncHandler(applyToJob));
applicationsRouter.put('/status', authMiddleware, requireRole(['CATERER']), validateRequest(updateApplicationStatusSchema), asyncHandler(updateApplicationStatus));
