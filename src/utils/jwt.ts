import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import type { AuthTokenPayload, PublicUser, Role } from '../types/domain';

function isRole(value: unknown): value is Role {
  return (
    value === 'STUDENT' ||
    value === 'CATERER' ||
    value === 'ADMIN'
  );
}

function isAuthTokenPayload(payload: string | jwt.JwtPayload): payload is jwt.JwtPayload & AuthTokenPayload {
  return typeof payload !== 'string'
    && typeof payload.sub === 'string'
    && typeof payload.email === 'string'
    && typeof payload.name === 'string'
    && isRole(payload.role);
}

export function signAuthToken(user: PublicUser): string {
  const tokenOptions: jwt.SignOptions = {
    subject: user.id,
  };

  tokenOptions.expiresIn = env.JWT_EXPIRES_IN as Exclude<jwt.SignOptions['expiresIn'], undefined>;

  return jwt.sign({ email: user.email, name: user.name, role: user.role }, env.JWT_SECRET, tokenOptions);
}

export function verifyAuthToken(token: string): AuthTokenPayload {
  const decoded = jwt.verify(token, env.JWT_SECRET);
  if (!isAuthTokenPayload(decoded)) {
    throw new Error('Invalid token payload');
  }

  return decoded;
}
