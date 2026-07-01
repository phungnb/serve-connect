import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../utils/errors';

export function errorHandler(error: unknown, _req: Request, res: Response, _next: NextFunction) {

  console.error('==== ERROR START ====');
  console.error(error);
  console.error('==== ERROR END ====');

  if (error instanceof AppError) {
    return res.status(error.statusCode).json({ error: error.message });
  }

  if (error instanceof Error) {
    return res.status(500).json({ error: error.message });
  }

  return res.status(500).json({ error: 'Internal server error' });
}