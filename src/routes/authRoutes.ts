import { Router } from 'express';
import { login, me, register } from '../controllers/authController';
import { asyncHandler } from '../utils/asyncHandler';
import { validateRequest } from '../middleware/validateRequest';
import { loginSchema, registerSchema } from '../validators/authValidators';
import { authMiddleware } from '../middleware/authMiddleware';

export const authRouter = Router();

authRouter.post('/register', validateRequest(registerSchema), asyncHandler(register));
authRouter.post('/login', validateRequest(loginSchema), asyncHandler(login));
authRouter.get('/me', authMiddleware, asyncHandler(me));
