import 'dart:math';

import '../../auth/models/app_user.dart';
import '../models/job_application.dart';
import '../models/job_post.dart';
import 'marketplace_repository.dart';

class MockMarketplaceRepository implements MarketplaceRepository {
  MockMarketplaceRepository() {
    _seedData();
  }

  final List<AppUser> _users = <AppUser>[];
  final List<_Credential> _credentials = <_Credential>[];
  final List<JobPost> _jobs = <JobPost>[];
  final List<JobApplication> _applications = <JobApplication>[];
  final Random _random = Random(8);

  void _seedData() {
    final student = AppUser(id: 'student-1', name: 'Ava Patel', email: 'student@serveconnect.app', role: AppRole.student);
    final caterer = AppUser(id: 'caterer-1', name: 'Harvest Catering Co.', email: 'caterer@serveconnect.app', role: AppRole.caterer);

    _users.addAll(<AppUser>[student, caterer]);
    _credentials.addAll(<_Credential>[
      _Credential(email: student.email, password: 'password123', role: student.role, userId: student.id),
      _Credential(email: caterer.email, password: 'password123', role: caterer.role, userId: caterer.id),
    ]);

    _jobs.addAll(<JobPost>[
      JobPost(
        id: 'job-1',
        catererId: caterer.id,
        catererName: caterer.name,
        title: 'Campus Gala Servers',
        description: 'Serve plated dinner and support guest flow for a 300-person university gala.',
        eventDate: DateTime.now().add(const Duration(days: 4)),
        startTime: '17:30',
        endTime: '22:00',
        salaryAmount: 22.5,
        workersNeeded: 6,
        location: 'Downtown Event Hall',
        status: 'OPEN',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      JobPost(
        id: 'job-2',
        catererId: caterer.id,
        catererName: caterer.name,
        title: 'Weekend Brunch Support',
        description: 'Assist with buffet setup, beverage service, and clean-up at a private brunch event.',
        eventDate: DateTime.now().add(const Duration(days: 8)),
        startTime: '09:00',
        endTime: '14:00',
        salaryAmount: 20,
        workersNeeded: 4,
        location: 'Lakeside Residence Club',
        status: 'OPEN',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ]);

    _applications.addAll(<JobApplication>[
      JobApplication(
        id: 'app-1',
        jobId: 'job-1',
        studentId: student.id,
        studentName: student.name,
        studentEmail: student.email,
        status: 'PENDING',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      JobApplication(
        id: 'app-2',
        jobId: 'job-1',
        studentId: 'student-2',
        studentName: 'Marcus Lee',
        studentEmail: 'marcus@serveconnect.app',
        status: 'PENDING',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);
  }

  @override
  Future<AuthSession> login({required String email, required String password, required AppRole role}) async {
    final credential = _credentials.where((candidate) => candidate.email == email && candidate.password == password && candidate.role == role).firstOrNull;
    if (credential == null) {
      throw StateError('Invalid email, password, or role');
    }

    final user = _users.firstWhere((candidate) => candidate.id == credential.userId);
    _session = AuthSession(token: 'mock-token-${user.id}', user: user);
    return _session!;
  }

  AuthSession? _session;

  @override
  Future<AuthSession> register({required String name, required String email, required String password, required AppRole role}) async {
    if (_users.any((user) => user.email == email)) {
      throw StateError('This email is already registered');
    }

    final user = AppUser(
      id: '${role.name}-${_random.nextInt(900000) + 100000}',
      name: name,
      email: email,
      role: role,
    );
    _users.add(user);
    _credentials.add(_Credential(email: email, password: password, role: role, userId: user.id));
    _session = AuthSession(token: 'mock-token-${user.id}', user: user);
    return _session!;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    return _session;
  }

  @override
  Future<void> clearSession() async {
    _session = null;
  }

  @override
  Future<List<JobPost>> fetchJobs() async {
    return List<JobPost>.unmodifiable(_jobs.where((job) => job.status == 'OPEN'));
  }

  @override
  Future<List<JobPost>> fetchMyJobs(String catererId) async {
    return List<JobPost>.unmodifiable(_jobs.where((job) => job.catererId == catererId));
  }

  @override
  Future<List<JobApplication>> fetchApplicants(String jobId) async {
    final applicants = _applications.where((application) => application.jobId == jobId).toList();
    return List<JobApplication>.unmodifiable(applicants);
  }

  @override
  Future<List<JobApplication>> fetchStudentApplications(String studentId) async {
    return List<JobApplication>.unmodifiable(_applications.where((application) => application.studentId == studentId));
  }

  @override
  Future<JobPost> createJob({required String ownerId, required CreateJobDraft draft}) async {
    final owner = _users.firstWhere((user) => user.id == ownerId && user.role == AppRole.caterer);
    final job = JobPost(
      id: 'job-${_random.nextInt(900000) + 100000}',
      catererId: owner.id,
      catererName: owner.name,
      title: draft.title,
      description: draft.description,
      eventDate: draft.eventDate,
      startTime: draft.startTime,
      endTime: draft.endTime,
      salaryAmount: draft.salaryAmount,
      workersNeeded: draft.workersNeeded,
      location: draft.location,
      status: 'OPEN',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _jobs.insert(0, job);
    return job;
  }

  @override
  Future<JobApplication> applyToJob({required String studentId, required String jobId}) async {
    final job = _jobs.firstWhere((candidate) => candidate.id == jobId);
    if (job.status != 'OPEN') {
      throw StateError('This job is not open');
    }

    if (_applications.any((application) => application.jobId == jobId && application.studentId == studentId)) {
      throw StateError('You already applied to this job');
    }

    final student = _users.firstWhere((user) => user.id == studentId && user.role == AppRole.student);
    final application = JobApplication(
      id: 'app-${_random.nextInt(900000) + 100000}',
      jobId: job.id,
      studentId: student.id,
      studentName: student.name,
      studentEmail: student.email,
      status: 'PENDING',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _applications.insert(0, application);
    return application;
  }

  @override
  Future<JobApplication> updateApplicationStatus({required String ownerId, required String applicationId, required String status}) async {
    final index = _applications.indexWhere((application) => application.id == applicationId);
    if (index < 0) {
      throw StateError('Application not found');
    }

    final application = _applications[index];
    final job = _jobs.firstWhere((candidate) => candidate.id == application.jobId);
    if (job.catererId != ownerId) {
      throw StateError('You can only manage your own job applications');
    }

    final updated = JobApplication(
      id: application.id,
      jobId: application.jobId,
      studentId: application.studentId,
      studentName: application.studentName,
      studentEmail: application.studentEmail,
      status: status,
      createdAt: application.createdAt,
      updatedAt: DateTime.now(),
    );
    _applications[index] = updated;

    final acceptedCount = _applications.where((item) => item.jobId == job.id && item.status == 'ACCEPTED').length;
    if (acceptedCount >= job.workersNeeded) {
      final jobIndex = _jobs.indexWhere((candidate) => candidate.id == job.id);
      _jobs[jobIndex] = JobPost(
        id: job.id,
        catererId: job.catererId,
        catererName: job.catererName,
        title: job.title,
        description: job.description,
        eventDate: job.eventDate,
        startTime: job.startTime,
        endTime: job.endTime,
        salaryAmount: job.salaryAmount,
        workersNeeded: job.workersNeeded,
        location: job.location,
        status: 'FILLED',
        createdAt: job.createdAt,
        updatedAt: DateTime.now(),
      );
    }

    return updated;
  }

  @override
  Future<void> logout() async {}
}

class _Credential {
  const _Credential({required this.email, required this.password, required this.role, required this.userId});

  final String email;
  final String password;
  final AppRole role;
  final String userId;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
