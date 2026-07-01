ALTER TABLE users
  ADD COLUMN phone_number VARCHAR(30) NULL AFTER role,
  ADD COLUMN address VARCHAR(255) NULL AFTER phone_number;

CREATE INDEX idx_users_role ON users (role);
CREATE INDEX idx_users_name ON users (name);
CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_jobs_title ON jobs (title);