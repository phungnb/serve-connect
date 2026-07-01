import mysql, { type PoolConnection, type ResultSetHeader, type RowDataPacket } from 'mysql2/promise';
import { env } from './env';

export interface QueryResult<T> {
  rows: T[];
  rowCount: number;
}

export interface DbExecutor {
  query<T = unknown>(sql: string, values?: readonly unknown[]): Promise<QueryResult<T>>;
}

const shouldUseSsl = env.MYSQL_SSL || env.NODE_ENV === 'production';
console.log("DATABASE_URL:", env.DATABASE_URL);
const mysqlPool = shouldUseSsl
  ? mysql.createPool({
      uri: env.DATABASE_URL,
      connectionLimit: 10,
      ssl: { rejectUnauthorized: false },
      namedPlaceholders: false,
    })
  : mysql.createPool({
      uri: env.DATABASE_URL,
      connectionLimit: 10,
      namedPlaceholders: false,
    });

function toQueryResult<T>(rows: RowDataPacket[] | ResultSetHeader): QueryResult<T> {
  if (Array.isArray(rows)) {
    return {
      rows: rows as T[],
      rowCount: rows.length,
    };
  }

  return {
    rows: [] as T[],
    rowCount: rows.affectedRows ?? 0,
  };
}

function createExecutor(connection: Pick<PoolConnection, 'query'>): DbExecutor {
  return {
    async query<T = unknown>(sql: string, values: readonly unknown[] = []): Promise<QueryResult<T>> {
      const [rows] = await connection.query<RowDataPacket[] | ResultSetHeader>(sql, values as unknown[]);
      return toQueryResult<T>(rows);
    },
  };
}

export const pool: DbExecutor = {
  async query<T = unknown>(sql: string, values: readonly unknown[] = []): Promise<QueryResult<T>> {
    const [rows] = await mysqlPool.query<RowDataPacket[] | ResultSetHeader>(sql, values as unknown[]);
    return toQueryResult<T>(rows);
  },
};

export async function withTransaction<T>(callback: (client: DbExecutor) => Promise<T>): Promise<T> {
  const connection = await mysqlPool.getConnection();
  try {
    await connection.beginTransaction();
    const result = await callback(createExecutor(connection));
    await connection.commit();
    return result;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

export async function closePool(): Promise<void> {
  await mysqlPool.end();
}
