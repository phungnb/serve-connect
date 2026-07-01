import { z } from 'zod';

export const applySchema = z.object({
  body: z.object({
    jobId: z.string().uuid('jobId must be a valid UUID'),
  }),
});

export const updateApplicationStatusSchema = z.object({
  body: z.object({
    applicationId: z.string().uuid('applicationId must be a valid UUID'),
    status: z.enum(['ACCEPTED', 'REJECTED'], {
      required_error: 'status is required',
      invalid_type_error: 'status must be ACCEPTED or REJECTED',
    }),
  }),
});
