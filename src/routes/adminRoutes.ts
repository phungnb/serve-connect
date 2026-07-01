import { Router } from 'express';
import { deleteAdminApplication, deleteAdminJob, deleteAdminUser, getAdminApplications, getAdminJobs, getAdminStats, getAdminUsers } from '../controllers/adminController';
import { authMiddleware } from '../middleware/authMiddleware';
import { requireRole } from '../middleware/requireRole';
import { asyncHandler } from '../utils/asyncHandler';

const router = Router();

router.get(
  '/stats',
  authMiddleware,
  requireRole(['ADMIN']),
  asyncHandler(getAdminStats)
);

router.get('/users', authMiddleware, requireRole(['ADMIN']), asyncHandler(getAdminUsers));
router.delete('/users/:id', authMiddleware, requireRole(['ADMIN']), asyncHandler(deleteAdminUser));

router.get('/jobs', authMiddleware, requireRole(['ADMIN']), asyncHandler(getAdminJobs));
router.delete('/jobs/:id', authMiddleware, requireRole(['ADMIN']), asyncHandler(deleteAdminJob));

router.get('/applications', authMiddleware, requireRole(['ADMIN']), asyncHandler(getAdminApplications));
router.delete('/applications/:id', authMiddleware, requireRole(['ADMIN']), asyncHandler(deleteAdminApplication));

export default router;