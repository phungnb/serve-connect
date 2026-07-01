import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../utils/errors';
import { verifyAuthToken } from '../utils/jwt';

export function authMiddleware(req: Request, _res: Response, next: NextFunction) {
  const authorizationHeader = req.header('authorization');
  if (!authorizationHeader) {
    return next(new AppError(401, 'Authorization header is required'));
  }

  const [scheme, token] = authorizationHeader.split(' ');
  if (scheme !== 'Bearer' || !token) {
    return next(new AppError(401, 'Authorization header must use Bearer token format'));
  }

  try {
    const decoded = verifyAuthToken(token);
    if (!decoded.sub) {
      return next(new AppError(401, 'Token subject is missing'));
    }

    req.user = {
      id: decoded.sub,
      name: decoded.name,
      email: decoded.email,
      role: decoded.role,
    };

    return next();
  } catch {
    return next(new AppError(401, 'Invalid or expired token'));
  }
}

export const authenticateToken = authMiddleware;
