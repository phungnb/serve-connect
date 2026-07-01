import type { NextFunction, Request, Response } from 'express';
import type { Role } from '../types/domain';
import { AppError } from '../utils/errors';

export function requireRole(allowedRoles: Role[]) {
  return (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(new AppError(401, 'Authentication required'));
    }

    if (!allowedRoles.includes(req.user.role)) {
      return next(new AppError(403, 'You do not have permission to perform this action'));
    }

    return next();
  };
}
