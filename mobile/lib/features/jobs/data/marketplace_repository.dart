import '../../auth/models/app_user.dart';
import '../models/job_application.dart';
import '../models/job_post.dart';

abstract class MarketplaceRepository {
  Future<AuthSession> login({required String email, required String password, required AppRole role});
  Future<AuthSession> register({required String name, required String email, required String password, required AppRole role});
  Future<AuthSession?> restoreSession();
  Future<void> clearSession();
  Future<List<JobPost>> fetchJobs();
  Future<List<JobPost>> fetchMyJobs(String catererId);
  Future<List<JobApplication>> fetchApplicants(String jobId);
  Future<List<JobApplication>> fetchStudentApplications(String studentId);
  Future<JobPost> createJob({required String ownerId, required CreateJobDraft draft});
  Future<JobApplication> applyToJob({required String studentId, required String jobId});
  Future<JobApplication> updateApplicationStatus({required String ownerId, required String applicationId, required String status});
  Future<void> logout();
}
