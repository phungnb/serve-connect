import { z } from 'zod';

const isoDateSchema = z.string().refine((value) => !Number.isNaN(Date.parse(value)), {
  message: 'eventDate must be a valid ISO date string',
});

const timeSchema = z.string().regex(/^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/, 'Time must be in HH:MM or HH:MM:SS format');

export const createJobSchema = z.object({
  body: z.object({
    title: z.string().trim().min(3).max(200),
    description: z.string().trim().min(10).max(4000),
    eventDate: isoDateSchema,
    startTime: timeSchema,
    endTime: timeSchema,
    salaryAmount: z.coerce.number().positive('Salary amount must be positive'),
    workersNeeded: z.coerce.number().int().positive('workersNeeded must be a positive integer'),
    locationString: z.string().trim().min(3).max(255),
  }).refine((data) => data.endTime > data.startTime, {
    message: 'endTime must be later than startTime',
    path: ['endTime'],
  }),
});
