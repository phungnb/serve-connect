import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../data/admin_repository.dart';
import '../models/admin_stats.dart';
import '../../../core/providers/api_provider.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(apiServiceProvider));
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return ref.read(adminRepositoryProvider).getStats();
});

final adminUsersProvider = FutureProvider.family<List<AdminUserRecord>, ({String? role, String? search})>((ref, filters) {
  return ref.read(adminRepositoryProvider).getUsers(search: filters.search, role: filters.role);
});

final adminJobsProvider = FutureProvider.family<List<AdminJobRecord>, String?>((ref, search) {
  return ref.read(adminRepositoryProvider).getJobs(search: search);
});

final adminApplicationsProvider = FutureProvider.family<List<AdminApplicationRecord>, ({String? search, String? status})>((ref, filters) {
  return ref.read(adminRepositoryProvider).getApplications(search: filters.search, status: filters.status);
});