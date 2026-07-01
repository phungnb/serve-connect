import '../../auth/models/app_user.dart';
import '../models/job_application.dart';
import '../models/job_post.dart';

class MarketplaceState {
  const MarketplaceState({
    required this.isInitializing,
    required this.isBusy,
    required this.user,
    required this.token,
    required this.jobs,
    required this.myJobs,
    required this.applicantsByJobId,
    required this.appliedJobIds,
    required this.applicationStatusByJobId,
    required this.errorMessage,
  });

  factory MarketplaceState.initial() {
    return const MarketplaceState(
      isInitializing: true,
      isBusy: false,
      user: null,
      token: null,
      jobs: <JobPost>[],
      myJobs: <JobPost>[],
      applicantsByJobId: <String, List<JobApplication>>{},
      appliedJobIds: <String>{},
      applicationStatusByJobId: <String, String>{},
      errorMessage: null,
    );
  }

  final bool isInitializing;
  final bool isBusy;
  final AppUser? user;
  final String? token;
  final List<JobPost> jobs;
  final List<JobPost> myJobs;
  final Map<String, List<JobApplication>> applicantsByJobId;
  final Set<String> appliedJobIds;
  final Map<String, String> applicationStatusByJobId;
  final String? errorMessage;

  bool get isAuthenticated => user != null;
  bool get isStudent => user?.role == AppRole.student;
  bool get isCaterer => user?.role == AppRole.caterer;

  MarketplaceState copyWith({
    bool? isInitializing,
    bool? isBusy,
    AppUser? user,
    String? token,
    bool clearUser = false,
    bool clearToken = false,
    List<JobPost>? jobs,
    List<JobPost>? myJobs,
    Map<String, List<JobApplication>>? applicantsByJobId,
    Set<String>? appliedJobIds,
    Map<String, String>? applicationStatusByJobId,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MarketplaceState(
      isInitializing: isInitializing ?? this.isInitializing,
      isBusy: isBusy ?? this.isBusy,
      user: clearUser ? null : user ?? this.user,
      token: clearToken ? null : token ?? this.token,
      jobs: jobs ?? this.jobs,
      myJobs: myJobs ?? this.myJobs,
      applicantsByJobId: applicantsByJobId ?? this.applicantsByJobId,
      appliedJobIds: appliedJobIds ?? this.appliedJobIds,
      applicationStatusByJobId: applicationStatusByJobId ?? this.applicationStatusByJobId,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
