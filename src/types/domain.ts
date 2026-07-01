import type { JwtPayload } from 'jsonwebtoken';

export type Role = 'STUDENT' | 'CATERER' | 'ADMIN';
export type ApplicationStatus = 'PENDING' | 'ACCEPTED' | 'REJECTED';
export type JobStatus = 'OPEN' | 'FILLED';

export interface AuthenticatedUser {
  id: string;
  name: string;
  email: string;
  role: Role;
}

export interface PublicUser extends AuthenticatedUser {
  createdAt: string;
  updatedAt: string;
  phoneNumber?: string | null;
  address?: string | null;
}

export interface AuthTokenPayload extends JwtPayload {
  role: Role;
  email: string;
  name: string;
}

export interface UserRow {
  id: string;
  name: string;
  email: string;
  password_hash: string;
  role: Role;
  phone_number?: string | null;
  address?: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface UserProfileRow extends UserRow {
  phone_number: string | null;
  address: string | null;
}

export interface AdminUserListRow {
  id: string;
  name: string;
  email: string;
  role: Role;
  phone_number: string | null;
  address: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface AdminJobListRow {
  id: string;
  caterer_id: string;
  caterer_name: string;
  title: string;
  description: string;
  event_date: string;
  start_time: string;
  end_time: string;
  salary_amount: string;
  workers_needed: number;
  location_string: string;
  status: JobStatus;
  created_at: Date;
  updated_at: Date;
  applications_count: string;
}

export interface AdminApplicationListRow {
  id: string;
  status: ApplicationStatus;
  job_id: string;
  job_title: string;
  student_id: string;
  student_name: string;
  student_email: string;
  caterer_id: string;
  caterer_name: string;
  created_at: Date;
  updated_at: Date;
}

export interface JobRow {
  id: string;
  caterer_id: string;
  title: string;
  description: string;
  event_date: string;
  start_time: string;
  end_time: string;
  salary_amount: string;
  workers_needed: number;
  location_string: string;
  status: JobStatus;
  created_at: Date;
  updated_at: Date;
}

export interface JobFeedRow extends JobRow {
  caterer_name: string;
  accepted_count: string;
}

export interface ApplicationRow {
  id: string;
  job_id: string;
  student_id: string;
  status: ApplicationStatus;
  created_at: Date;
  updated_at: Date;
}

export interface ApplicationOwnershipRow {
  application_id: string;
  job_id: string;
  current_status: ApplicationStatus;
  caterer_id: string;
  workers_needed: number;
}

export interface ApplicationRecordView {
  id: string;
  jobId: string;
  studentId: string;
  status: ApplicationStatus;
  createdAt: string;
  updatedAt: string;
}

export interface JobFeedItem {
  id: string;
  catererId: string;
  catererName: string;
  title: string;
  description: string;
  eventDate: string;
  startTime: string;
  endTime: string;
  salaryAmount: number;
  workersNeeded: number;
  locationString: string;
  status: JobStatus;
  acceptedWorkers: number;
  createdAt: string;
  updatedAt: string;
}

export interface JobApplicantRow {
  application_id: string;
  status: ApplicationStatus;
  student_id: string;
  student_name: string;
  student_email: string;
}
