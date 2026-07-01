import '../models/admin_stats.dart';
import '../../../core/network/api_service.dart';

class AdminRepository {
  AdminRepository(this._apiService);

  final ApiService _apiService;

  Future<AdminStats> getStats() async {
    final json = await _apiService.fetchAdminStats();
    return AdminStats.fromJson(json);
  }

  Future<List<AdminUserRecord>> getUsers({String? search, String? role}) async {
    final response = await _apiService.fetchAdminUsers(search: search, role: role);
    return response.map(AdminUserRecord.fromJson).toList();
  }

  Future<List<AdminJobRecord>> getJobs({String? search}) async {
    final response = await _apiService.fetchAdminJobs(search: search);
    return response.map(AdminJobRecord.fromJson).toList();
  }

  Future<List<AdminApplicationRecord>> getApplications({String? search, String? status}) async {
    final response = await _apiService.fetchAdminApplications(search: search, status: status);
    return response.map(AdminApplicationRecord.fromJson).toList();
  }

  Future<void> deleteUser(String id) => _apiService.deleteAdminUser(id);

  Future<void> deleteJob(String id) => _apiService.deleteAdminJob(id);

  Future<void> deleteApplication(String id) => _apiService.deleteAdminApplication(id);
}