import { Router } from 'express';
import { getProfile, updateProfile } from '../controllers/profileController';
import { authMiddleware } from '../middleware/authMiddleware';
import { asyncHandler } from '../utils/asyncHandler';

export const profileRouter = Router();

profileRouter.get('/', authMiddleware, asyncHandler(getProfile));
profileRouter.put('/', authMiddleware, asyncHandler(updateProfile));