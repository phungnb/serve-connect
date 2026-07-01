import { z } from 'zod';

export const registerSchema = z.object({
  body: z.object({
    name: z.string().trim().min(2, 'Name must be at least 2 characters long').max(100),
    email: z.string().trim().email('Email must be valid').toLowerCase(),
    password: z.string().min(8, 'Password must be at least 8 characters long').max(128),
    role: z.enum(['STUDENT', 'CATERER'], {
      required_error: 'Role is required',
      invalid_type_error: 'Role must be STUDENT or CATERER',
    }),
  }),
});

export const loginSchema = z.object({
  body: z.object({
    email: z.string().trim().email('Email must be valid').toLowerCase(),
    password: z.string().min(1, 'Password is required'),
  }),
});
