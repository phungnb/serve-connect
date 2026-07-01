CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('STUDENT', 'CATERER') NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_users_name_length CHECK (CHAR_LENGTH(name) >= 2)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS jobs (
  id CHAR(36) PRIMARY KEY,
  caterer_id CHAR(36) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  event_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  salary_amount DECIMAL(10, 2) NOT NULL,
  workers_needed INT NOT NULL,
  location_string VARCHAR(255) NOT NULL,
  status ENUM('OPEN', 'FILLED') NOT NULL DEFAULT 'OPEN',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_jobs_salary_positive CHECK (salary_amount > 0),
  CONSTRAINT chk_jobs_workers_positive CHECK (workers_needed > 0),
  CONSTRAINT chk_jobs_valid_time_window CHECK (end_time > start_time),
  CONSTRAINT fk_jobs_caterer FOREIGN KEY (caterer_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS applications (
  id CHAR(36) PRIMARY KEY,
  job_id CHAR(36) NOT NULL,
  student_id CHAR(36) NOT NULL,
  status ENUM('PENDING', 'ACCEPTED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT uq_applications_job_student UNIQUE (job_id, student_id),
  CONSTRAINT fk_applications_job FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  CONSTRAINT fk_applications_student FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_jobs_status_event_date ON jobs (status, event_date, start_time);
CREATE INDEX idx_jobs_caterer_id ON jobs (caterer_id);
CREATE INDEX idx_applications_job_id ON applications (job_id);
CREATE INDEX idx_applications_student_id ON applications (student_id);
CREATE INDEX idx_applications_status ON applications (status);
