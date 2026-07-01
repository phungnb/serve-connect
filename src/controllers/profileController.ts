import type { Request, Response } from 'express';
import { pool } from '../config/db';
import { AppError } from '../utils/errors';
import type { PublicUser, UserProfileRow } from '../types/domain';

function mapProfileRow(row: UserProfileRow): PublicUser {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    role: row.role,
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
    phoneNumber: null,
    address: null,
  };
}

async function loadProfile(userId: string): Promise<PublicUser> {
  const result = await pool.query<UserProfileRow>(
    `SELECT id, name, email, role, created_at, updated_at
     FROM users
     WHERE id = ?`,
    [userId],
  );

  if (result.rowCount === 0) {
    throw new AppError(404, 'Requested resource not found');
  }

  return mapProfileRow(result.rows[0]!);
}

export async function getProfile(req: Request, res: Response) {
  if (!req.user) {
    throw new AppError(401, 'Authentication required');
  }

  const profile = await loadProfile(req.user.id);
  res.status(200).json({ user: profile });
}

export async function updateProfile(req: Request, res: Response) {
  if (!req.user) {
    throw new AppError(401, 'Authentication required');
  }

  const { name, phoneNumber, address } = req.body as {
    name?: string;
    phoneNumber?: string | null;
    address?: string | null;
  };

  const current = await loadProfile(req.user.id);
  const nextName = name?.trim() || current.name;
  const nextPhone = phoneNumber === undefined ? current.phoneNumber ?? null : phoneNumber?.trim() || null;
  const nextAddress = address === undefined ? current.address ?? null : address?.trim() || null;

  await pool.query(
    `UPDATE users
     SET name = ?, phone_number = ?, address = ?
     WHERE id = ?`,
    [nextName, nextPhone, nextAddress, req.user.id],
  );

  const updatedProfile = await loadProfile(req.user.id);
  res.status(200).json({ user: updatedProfile });
}