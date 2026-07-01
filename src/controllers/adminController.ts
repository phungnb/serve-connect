import type { Request, Response } from 'express';
import { randomUUID } from 'node:crypto';
import { pool } from '../config/db';
import { AppError } from '../utils/errors';
import type { AdminApplicationListRow, AdminJobListRow, AdminUserListRow } from '../types/domain';

export async function getAdminStats(_req: Request, res: Response) {
  const totalUsers = await pool.query<{ count: number }>(
    'SELECT COUNT(*) AS count FROM users'
  );

  const students = await pool.query<{ count: number }>(
    "SELECT COUNT(*) AS count FROM users WHERE role='STUDENT'"
  );

  const caterers = await pool.query<{ count: number }>(
    "SELECT COUNT(*) AS count FROM users WHERE role='CATERER'"
  );

  const admins = await pool.query<{ count: number }>(
    "SELECT COUNT(*) AS count FROM users WHERE role='ADMIN'"
  );

  const jobs = await pool.query<{ count: number }>(
    'SELECT COUNT(*) AS count FROM jobs'
  );

  const applications = await pool.query<{ count: number }>(
    'SELECT COUNT(*) AS count FROM applications'
  );

  res.status(200).json({
    totalUsers: Number(totalUsers.rows[0]?.count ?? 0),
    students: Number(students.rows[0]?.count ?? 0),
    caterers: Number(caterers.rows[0]?.count ?? 0),
    admins: Number(admins.rows[0]?.count ?? 0),
    jobs: Number(jobs.rows[0]?.count ?? 0),
    applications: Number(applications.rows[0]?.count ?? 0),
  });
}

export async function getAdminUsers(req: Request, res: Response) {
  const search = String(req.query.search ?? '').trim();
  const role = String(req.query.role ?? '').trim().toUpperCase();
  const values: unknown[] = [];
  const conditions: string[] = [];

  if (search) {
    values.push(`%${search}%`);
    conditions.push('(name LIKE ? OR email LIKE ?)');
    values.push(`%${search}%`);
  }

  if (role && ['STUDENT', 'CATERER', 'ADMIN'].includes(role)) {
    values.push(role);
    conditions.push('role = ?');
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
  const result = await pool.query<AdminUserListRow>(
    `SELECT id, name, email, role, NULL AS phone_number, NULL AS address, created_at, updated_at
     FROM users
     ${whereClause}
     ORDER BY created_at DESC`,
    values,
  );

  res.status(200).json({ users: result.rows });
}

export async function deleteAdminUser(req: Request, res: Response) {
  const { id } = req.params as { id: string };
  const result = await pool.query('DELETE FROM users WHERE id = ?', [id]);
  if (result.rowCount === 0) {
    throw new AppError(404, 'Requested resource not found');
  }
  res.status(200).json({ ok: true });
}

export async function getAdminJobs(req: Request, res: Response) {
  const search = String(req.query.search ?? '').trim();
  const values: unknown[] = [];
  const conditions: string[] = [];

  if (search) {
    values.push(`%${search}%`);
    conditions.push('(j.title LIKE ? OR j.location_string LIKE ? OR u.name LIKE ?)');
    values.push(`%${search}%`);
    values.push(`%${search}%`);
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
  const result = await pool.query<AdminJobListRow>(
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
      COUNT(a.id) AS applications_count
     FROM jobs j
     INNER JOIN users u ON u.id = j.caterer_id
     LEFT JOIN applications a ON a.job_id = j.id
     ${whereClause}
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
     ORDER BY j.created_at DESC`,
    values,
  );

  res.status(200).json({ jobs: result.rows });
}

export async function deleteAdminJob(req: Request, res: Response) {
  const { id } = req.params as { id: string };
  const result = await pool.query('DELETE FROM jobs WHERE id = ?', [id]);
  if (result.rowCount === 0) {
    throw new AppError(404, 'Requested resource not found');
  }
  res.status(200).json({ ok: true });
}

export async function getAdminApplications(req: Request, res: Response) {
  const search = String(req.query.search ?? '').trim();
  const status = String(req.query.status ?? '').trim().toUpperCase();
  const values: unknown[] = [];
  const conditions: string[] = [];

  if (search) {
    values.push(`%${search}%`);
    conditions.push('(j.title LIKE ? OR s.name LIKE ? OR s.email LIKE ? OR u.name LIKE ?)');
    values.push(`%${search}%`);
    values.push(`%${search}%`);
    values.push(`%${search}%`);
  }

  if (status && ['PENDING', 'ACCEPTED', 'REJECTED'].includes(status)) {
    values.push(status);
    conditions.push('a.status = ?');
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
  const result = await pool.query<AdminApplicationListRow>(
    `SELECT
      a.id,
      a.status,
      a.job_id,
      j.title AS job_title,
      a.student_id,
      s.name AS student_name,
      s.email AS student_email,
      j.caterer_id,
      u.name AS caterer_name,
      a.created_at,
      a.updated_at
     FROM applications a
     INNER JOIN jobs j ON j.id = a.job_id
     INNER JOIN users s ON s.id = a.student_id
     INNER JOIN users u ON u.id = j.caterer_id
     ${whereClause}
     ORDER BY a.created_at DESC`,
    values,
  );

  res.status(200).json({ applications: result.rows });
}

export async function deleteAdminApplication(req: Request, res: Response) {
  const { id } = req.params as { id: string };
  const result = await pool.query('DELETE FROM applications WHERE id = ?', [id]);
  if (result.rowCount === 0) {
    throw new AppError(404, 'Requested resource not found');
  }
  res.status(200).json({ ok: true });
}