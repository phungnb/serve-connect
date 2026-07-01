import type { Request, Response } from 'express';
import { randomUUID } from 'node:crypto';
import { pool, withTransaction } from '../config/db';
import { AppError } from '../utils/errors';
import type { ApplicationOwnershipRow, ApplicationRecordView, ApplicationRow, JobRow } from '../types/domain';

function mapApplicationRow(row: ApplicationRow): ApplicationRecordView {
  return {
    id: row.id,
    jobId: row.job_id,
    studentId: row.student_id,
    status: row.status,
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
  };
}

export async function applyToJob(req: Request, res: Response) {
  const user = req.user;
  if (!user) {
    throw new AppError(401, 'Authentication required');
  }

  const { jobId } = req.body as { jobId: string };
  const applicationId = randomUUID();

  try {
    const application = await withTransaction(async (client) => {
      const jobResult = await client.query<JobRow>(
        `SELECT * FROM jobs WHERE id = ? AND status = 'OPEN' FOR UPDATE`,
        [jobId],
      );

      if (jobResult.rowCount === 0) {
        throw new AppError(404, 'Open job not found');
      }

      const job = jobResult.rows[0]!;
      const acceptedResult = await client.query<{ accepted_count: string }>(
        `SELECT COUNT(*) AS accepted_count
         FROM applications
         WHERE job_id = ? AND status = 'ACCEPTED'`,
        [jobId],
      );

      if (Number(acceptedResult.rows[0]?.accepted_count ?? 0) >= job.workers_needed) {
        throw new AppError(409, 'This job is already full');
      }

      await client.query<ApplicationRow>(
        'INSERT INTO applications (id, job_id, student_id) VALUES (?, ?, ?)',
        [applicationId, jobId, user.id],
      );

      return mapApplicationRow({
        id: applicationId,
        job_id: jobId,
        student_id: user.id,
        status: 'PENDING',
        created_at: new Date(),
        updated_at: new Date(),
      });
    });

    res.status(201).json({ application });
  } catch (error) {
    if (error instanceof Error && 'code' in error && (error as { code?: string }).code === '23505') {
      throw new AppError(409, 'You have already applied to this job');
    }

    throw error;
  }
}

export async function updateApplicationStatus(req: Request, res: Response) {
  const user = req.user;
  if (!user) {
    throw new AppError(401, 'Authentication required');
  }

  const { applicationId, status } = req.body as { applicationId: string; status: 'ACCEPTED' | 'REJECTED' };

  const updatedApplication = await withTransaction(async (client) => {
    const result = await client.query<ApplicationOwnershipRow>(
      `SELECT
        a.id AS application_id,
        a.job_id,
        a.status AS current_status,
        j.caterer_id,
        j.workers_needed
       FROM applications a
       INNER JOIN jobs j ON j.id = a.job_id
       WHERE a.id = ?
       FOR UPDATE`,
      [applicationId],
    );

    if (result.rowCount === 0) {
      throw new AppError(404, 'Application not found');
    }

    const application = result.rows[0]!;
    if (application.caterer_id !== user.id) {
      throw new AppError(403, 'You can only manage applications for your own jobs');
    }

    if (application.current_status !== 'PENDING') {
      throw new AppError(409, 'Only pending applications can be updated');
    }

    if (status === 'ACCEPTED') {
      const acceptedCountResult = await client.query<{ accepted_count: string }>(
        `SELECT COUNT(*) AS accepted_count
         FROM applications
         WHERE job_id = ? AND status = 'ACCEPTED'`,
        [application.job_id],
      );

      if (Number(acceptedCountResult.rows[0]?.accepted_count ?? 0) >= application.workers_needed) {
        throw new AppError(409, 'This job is already filled');
      }
    }

    await client.query<ApplicationRow>(
      `UPDATE applications
       SET status = ?
       WHERE id = ?`,
      [status, applicationId],
    );

    const acceptedApplications = await client.query<{ accepted_count: string }>(
      `SELECT COUNT(*) AS accepted_count
       FROM applications
       WHERE job_id = ? AND status = 'ACCEPTED'`,
      [application.job_id],
    );

    if (status === 'ACCEPTED' && Number(acceptedApplications.rows[0]?.accepted_count ?? 0) >= application.workers_needed) {
      await client.query(`UPDATE jobs SET status = 'FILLED' WHERE id = ?`, [application.job_id]);
    }

    return {
      id: applicationId,
      job_id: application.job_id,
      student_id: user.id,
      status,
      created_at: new Date(),
      updated_at: new Date(),
    };
  });

  res.status(200).json({ application: mapApplicationRow(updatedApplication) });
}
