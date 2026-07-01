import type { Request, Response } from 'express';
import { randomUUID } from 'node:crypto';
import { pool } from '../config/db';
import { comparePassword, hashPassword } from '../utils/password';
import { AppError } from '../utils/errors';
import { signAuthToken } from '../utils/jwt';
import type { PublicUser, UserProfileRow, UserRow } from '../types/domain';

function mapUserRow(row: UserProfileRow | UserRow): PublicUser {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    role: row.role,
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
    phoneNumber: 'phone_number' in row ? row.phone_number ?? null : null,
    address: 'address' in row ? row.address ?? null : null,
  };
}

async function loadUserById(userId: string): Promise<PublicUser> {
  const result = await pool.query<UserProfileRow>(
    `SELECT id, name, email, role, created_at, updated_at
     FROM users
     WHERE id = ?`,
    [userId],
  );

  if (result.rowCount === 0) {
    throw new AppError(404, 'Requested resource not found');
  }

  return mapUserRow(result.rows[0]!);
}

export async function register(req: Request, res: Response) {
  const { name, email, password, role } = req.body as {
    name: string;
    email: string;
    password: string;
    role: 'STUDENT' | 'CATERER';  };

  const passwordHash = await hashPassword(password);
  const userId = randomUUID();
  try {
    await pool.query<UserRow>(
      'INSERT INTO users (id, name, email, password_hash, role) VALUES (?, ?, ?, ?, ?)',
      [userId, name, email, passwordHash, role],
    );
  } catch (error) {
    if (error instanceof Error && 'errno' in error && (error as { errno?: number }).errno === 1062) {
      throw new AppError(409, 'Email already in use');
    }

    throw error;
  }

  const user = await loadUserById(userId);
  const token = signAuthToken(user);

  res.status(201).json({ user, token });
}

export async function login(req: Request, res: Response) {
  const { email, password } = req.body as { email: string; password: string };

  const result = await pool.query<UserRow>('SELECT * FROM users WHERE email = ?', [email]);
  if (result.rowCount === 0) {
    throw new AppError(401, 'Invalid email or password');
  }

  const userRow = result.rows[0]!;
  const passwordMatches = await comparePassword(password, userRow.password_hash);
  if (!passwordMatches) {
    throw new AppError(401, 'Invalid email or password');
  }

  const user = mapUserRow(userRow);
  const token = signAuthToken(user);

  res.status(200).json({ user, token });
}

export async function me(req: Request, res: Response) {
  if (!req.user) {
    throw new AppError(401, 'Authentication required');
  }

  const user = await loadUserById(req.user.id);
  res.status(200).json({ user });
}
