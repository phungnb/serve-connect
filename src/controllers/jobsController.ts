import type { Request, Response } from 'express';
import { randomUUID } from 'node:crypto';
import { pool } from '../config/db';
import { AppError } from '../utils/errors';
import type { JobApplicantRow, JobFeedItem, JobFeedRow, JobRow } from '../types/domain';

function mapJobFeedRow(row: JobFeedRow): JobFeedItem {
  return {
    id: row.id,
    catererId: row.caterer_id,
    catererName: row.caterer_name,
    title: row.title,
    description: row.description,
    eventDate: row.event_date,
    startTime: row.start_time,
    endTime: row.end_time,
    salaryAmount: Number(row.salary_amount),
    workersNeeded: row.workers_needed,
    locationString: row.location_string,
    status: row.status,
    acceptedWorkers: Number(row.accepted_count),
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
  };
}

export async function createJob(req: Request, res: Response) {
  if (!req.user) {
    throw new AppError(401, 'Authentication required');
  }

  const {
    title,
    description,
    eventDate,
    startTime,
    endTime,
    salaryAmount,
    workersNeeded,
    locationString,
  } = req.body as {
    title: string;
    description: string;
    eventDate: string;
    startTime: string;
    endTime: string;
    salaryAmount: number;
    workersNeeded: number;
    locationString: string;
  };

  const jobId = randomUUID();

  await pool.query<JobRow>(
    `INSERT INTO jobs (
      id,
      caterer_id,
      title,
      description,
      event_date,
      start_time,
      end_time,
      salary_amount,
      workers_needed,
      location_string
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      jobId,
      req.user.id,
      title,
      description,
      eventDate,
      startTime,
      endTime,
      salaryAmount,
      workersNeeded,
      locationString,
    ],
  );

  const job = {
    id: jobId,
    caterer_id: req.user.id,
    title,
    description,
    event_date: eventDate,
    start_time: startTime,
    end_time: endTime,
    salary_amount: salaryAmount.toFixed(2),
    workers_needed: workersNeeded,
    location_string: locationString,
    status: 'OPEN' as const,
    created_at: new Date(),
    updated_at: new Date(),
  } satisfies JobRow;

  res.status(201).json({
    job: {
      id: job.id,
      catererId: job.caterer_id,
      title: job.title,
      description: job.description,
      eventDate: job.event_date,
      startTime: job.start_time,
      endTime: job.end_time,
      salaryAmount: Number(job.salary_amount),
      workersNeeded: job.workers_needed,
      locationString: job.location_string,
      status: job.status,
      createdAt: job.created_at.toISOString(),
      updatedAt: job.updated_at.toISOString(),
    },
  });
}

export async function listJobs(_req: Request, res: Response) {
  const result = await pool.query<JobFeedRow>(
    `SELECT
      j.id,
      j.caterer_id,
      u.name AS caterer_name,
      j.title,
      j.description,
      j.event_date,
      j.start_time,
      j.end_time,
      j.salary_amount,
      j.workers_needed,
      j.location_string,
      j.status,
      j.created_at,
      j.updated_at,
      COALESCE(SUM(CASE WHEN a.status = 'ACCEPTED' THEN 1 ELSE 0 END), 0) AS accepted_count
    FROM jobs j
    INNER JOIN users u ON u.id = j.caterer_id
    LEFT JOIN applications a ON a.job_id = j.id
    WHERE j.status = 'OPEN'
    GROUP BY
      j.id,
      j.caterer_id,
      u.name,
      j.title,
      j.description,
      j.event_date,
      j.start_time,
      j.end_time,
      j.salary_amount,
      j.workers_needed,
      j.location_string,
      j.status,
      j.created_at,
      j.updated_at
    ORDER BY j.event_date ASC, j.start_time ASC, j.created_at DESC`,
  );

  res.status(200).json({
    jobs: result.rows.map(mapJobFeedRow),
  });
}

export async function listJobApplicants(req: Request, res: Response) {
  if (!req.user) {
    throw new AppError(401, 'Authentication required');
  }

  if (req.user.role !== 'CATERER') {
    throw new AppError(403, 'Only caterers can view job applicants');
  }

  const { jobId } = req.params as { jobId: string };

  const ownershipResult = await pool.query<{ id: string }>(
    `SELECT id
     FROM jobs
     WHERE id = ? AND caterer_id = ?`,
    [jobId, req.user.id],
  );

  if (ownershipResult.rowCount === 0) {
    throw new AppError(404, 'Job not found or you do not own this job');
  }

  const applicantsResult = await pool.query<JobApplicantRow>(
    `SELECT
      a.id AS application_id,
      a.status,
      u.id AS student_id,
      u.name AS student_name,
      u.email AS student_email
     FROM applications a
     INNER JOIN users u ON u.id = a.student_id
     WHERE a.job_id = ?
     ORDER BY a.created_at ASC`,
    [jobId],
  );

  res.status(200).json({
    applicants: applicantsResult.rows.map((row) => ({
      application_id: row.application_id,
      status: row.status,
      student_id: row.student_id,
      student_name: row.student_name,
      student_email: row.student_email,
    })),
  });
}
