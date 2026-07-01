import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/app_user.dart';
import '../data/marketplace_repository.dart';
import '../data/mock_marketplace_repository.dart';
import '../models/job_application.dart';
import '../models/job_post.dart';
import 'marketplace_state.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../core/providers/api_provider.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockMarketplaceRepository();
  }

  return RemoteMarketplaceRepository(ref.read(apiServiceProvider));
});

class MarketplaceController extends StateNotifier<MarketplaceState> {
  MarketplaceController(this._repository) : super(MarketplaceState.initial()) {
    unawaited(_restoreSession());
  }

  final MarketplaceRepository _repository;

  Future<void> _restoreSession() async {
    try {
      final session = await _repository.restoreSession();
      if (session == null) {
        state = state.copyWith(isInitializing: false, clearUser: true, clearToken: true);
        return;
      }

      state = state.copyWith(
        isInitializing: false,
        user: session.user,
        token: session.token,
        clearErrorMessage: true,
      );
      await _afterAuth(session.user);
    } catch (error) {
      state = state.copyWith(isInitializing: false, clearUser: true, clearToken: true, errorMessage: error.toString());
    }
  }

  Future<void> clearError() async {
    state = state.copyWith(clearErrorMessage: true);
  }

  Future<void> loadPublicJobs() async {
    try {
      final jobs = await _repository.fetchJobs();
      state = state.copyWith(jobs: jobs);
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> login({required String email, required String password, required AppRole role}) async {
    state = state.copyWith(isBusy: true, clearErrorMessage: true);
    try {
      final session = await _repository.login(email: email, password: password, role: role);
      state = state.copyWith(isBusy: false, user: session.user, token: session.token, clearErrorMessage: true);
      await _afterAuth(session.user);
    } catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.toString());
      rethrow;
    }
  }

  Future<void> register({required String name, required String email, required String password, required AppRole role}) async {
    state = state.copyWith(isBusy: true, clearErrorMessage: true);
    try {
      final session = await _repository.register(name: name, email: email, password: password, role: role);
      state = state.copyWith(isBusy: false, user: session.user, token: session.token, clearErrorMessage: true);
      await _afterAuth(session.user);
    } catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.toString());
      rethrow;
    }
  }

  Future<void> _afterAuth(AppUser user) async {
    if (user.role == AppRole.student) {
      await loadStudentData(user.id);
      return;
    }
    await loadCatererData(user.id);
  }

  Future<void> loadStudentData(String studentId) async {
    final results = await Future.wait(<Future<dynamic>>[
      _repository.fetchJobs(),
      _repository.fetchStudentApplications(studentId),
    ]);

    final jobs = results[0] as List<JobPost>;
    final applications = results[1] as List<JobApplication>;
    final appliedJobIds = applications.map((application) => application.jobId).toSet();
    final applicationStatusByJobId = <String, String>{
      for (final application in applications) application.jobId: application.status,
    };
    state = state.copyWith(
      jobs: jobs,
      appliedJobIds: appliedJobIds,
      applicationStatusByJobId: applicationStatusByJobId,
    );
  }

  Future<void> loadCatererData(String catererId) async {
    final jobs = await _repository.fetchMyJobs(catererId);
    state = state.copyWith(myJobs: jobs);
  }

  Future<void> refreshDashboard() async {
    final user = state.user;
    if (user == null) {
      await loadPublicJobs();
      return;
    }

    if (user.role == AppRole.student) {
      await loadStudentData(user.id);
    } else {
      await loadCatererData(user.id);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = MarketplaceState.initial().copyWith(isInitializing: false, jobs: state.jobs);
  }

  Future<void> createJob({required CreateJobDraft draft}) async {
    final user = state.user;
    if (user == null || user.role != AppRole.caterer) {
      throw StateError('Only caterers can create jobs');
    }

    state = state.copyWith(isBusy: true, clearErrorMessage: true);
    try {
      final job = await _repository.createJob(ownerId: user.id, draft: draft);
      final updatedJobs = <JobPost>[job, ...state.myJobs];
      state = state.copyWith(isBusy: false, myJobs: updatedJobs, jobs: [job, ...state.jobs]);
    } catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.toString());
      rethrow;
    }
  }

  Future<void> applyToJob(JobPost job) async {
    final user = state.user;
    if (user == null || user.role != AppRole.student) {
      throw StateError('Only students can apply to jobs');
    }

    if (state.appliedJobIds.contains(job.id)) {
      return;
    }

    state = state.copyWith(isBusy: true, clearErrorMessage: true);
    try {
      final application = await _repository.applyToJob(studentId: user.id, jobId: job.id);
      final updatedApplied = {...state.appliedJobIds, application.jobId};
      final updatedStatuses = {
        ...state.applicationStatusByJobId,
        application.jobId: application.status,
      };
      state = state.copyWith(isBusy: false, appliedJobIds: updatedApplied, applicationStatusByJobId: updatedStatuses);
      await loadPublicJobs();
    } catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.toString());
      rethrow;
    }
  }

  Future<void> loadApplicants(String jobId) async {
    final applicants = await _repository.fetchApplicants(jobId);
    final updated = <String, List<JobApplication>>{
      ...state.applicantsByJobId,
      jobId: applicants,
    };
    state = state.copyWith(applicantsByJobId: updated);
  }

  Future<void> updateApplicationStatus({required String applicationId, required String status, required String jobId}) async {
    final user = state.user;
    if (user == null || user.role != AppRole.caterer) {
      throw StateError('Only caterers can update applications');
    }

    state = state.copyWith(isBusy: true, clearErrorMessage: true);
    try {
      await _repository.updateApplicationStatus(ownerId: user.id, applicationId: applicationId, status: status);
      final applicants = await _repository.fetchApplicants(jobId);
      final myJobs = await _repository.fetchMyJobs(user.id);
      state = state.copyWith(
        isBusy: false,
        applicantsByJobId: {...state.applicantsByJobId, jobId: applicants},
        myJobs: myJobs,
      );
      await loadPublicJobs();
    } catch (error) {
      state = state.copyWith(isBusy: false, errorMessage: error.toString());
      rethrow;
    }
  }
}

final marketplaceControllerProvider = StateNotifierProvider<MarketplaceController, MarketplaceState>((ref) {
  return MarketplaceController(ref.read(marketplaceRepositoryProvider));
});

class RemoteMarketplaceRepository implements MarketplaceRepository {
  RemoteMarketplaceRepository(this._apiService);

  final ApiService _apiService;
  static const String _sessionTokenKey = 'serveconnect.session.token';
  static const String _sessionUserKey = 'serveconnect.session.user';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> _saveSession(AuthSession session) async {
    final prefs = await _prefs;
    await prefs.setString(_sessionTokenKey, session.token);
    await prefs.setString(_sessionUserKey, jsonEncode(session.user.toJson()));
  }

  Future<AuthSession?> _readPersistedSession() async {
    final prefs = await _prefs;
    final token = prefs.getString(_sessionTokenKey);
    final userJson = prefs.getString(_sessionUserKey);

    if (token == null || userJson == null) {
      return null;
    }

    try {
      _apiService.setToken(token);
      final user = await _apiService.fetchCurrentUser();
      return AuthSession(token: token, user: user);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  @override
  Future<AuthSession> login({required String email, required String password, required AppRole role}) async {
    final dto = await _apiService.login(email: email, password: password, role: role);
    _apiService.setToken(dto.token);
    final session = AuthSession(token: dto.token, user: dto.user);
    await _saveSession(session);
    return session;
  }

  @override
  Future<AuthSession> register({required String name, required String email, required String password, required AppRole role}) async {
    final dto = await _apiService.register(name: name, email: email, password: password, role: role);
    _apiService.setToken(dto.token);
    final session = AuthSession(token: dto.token, user: dto.user);
    await _saveSession(session);
    return session;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    return _readPersistedSession();
  }

  @override
  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_sessionUserKey);
    _apiService.clearToken();
  }

  @override
  Future<List<JobPost>> fetchJobs() => _apiService.fetchJobs();

  @override
  Future<List<JobPost>> fetchMyJobs(String catererId) async {
    final jobs = await _apiService.fetchJobs();
    return jobs.where((job) => job.catererId == catererId).toList();
  }

  @override
  Future<List<JobApplication>> fetchApplicants(String jobId) => _apiService.fetchApplicants(jobId: jobId);

  @override
  Future<List<JobApplication>> fetchStudentApplications(String studentId) async {
    return _apiService.fetchStudentApplications(studentId: studentId);
  }

  @override
  Future<JobPost> createJob({required String ownerId, required CreateJobDraft draft}) => _apiService.createJob(payload: draft.toJson());

  @override
  Future<JobApplication> applyToJob({required String studentId, required String jobId}) => _apiService.applyToJob(jobId: jobId);

  @override
  Future<JobApplication> updateApplicationStatus({required String ownerId, required String applicationId, required String status}) => _apiService.updateApplicationStatus(applicationId: applicationId, status: status);

  @override
  Future<void> logout() async {
    await clearSession();
  }
}
