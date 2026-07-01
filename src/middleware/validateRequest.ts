import type { NextFunction, Request, Response } from 'express';
import type { ZodTypeAny } from 'zod';
import { AppError } from '../utils/errors';

export function validateRequest(schema: ZodTypeAny) {
  return (req: Request, _res: Response, next: NextFunction) => {
    const parsed = schema.safeParse({
      body: req.body,
      params: req.params,
      query: req.query,
    });

    if (!parsed.success) {
      const message = parsed.error.issues.map((issue) => issue.message).join(', ');
      return next(new AppError(400, message));
    }

    (req as Request & { body: unknown }).body = parsed.data.body;
    (req as Request & { params: unknown }).params = parsed.data.params;
    (req as Request & { query: unknown }).query = parsed.data.query;
    return next();
  };
}
