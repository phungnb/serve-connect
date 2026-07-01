import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../../features/auth/models/app_user.dart';
import '../../features/jobs/models/job_application.dart';
import '../../features/jobs/models/job_post.dart';
import '../errors/app_exception.dart';

class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

  final Dio _dio;
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Future<T> _request<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (exception) {
      throw AppException.fromDio(exception);
    }
  }

  Options _options() {
    return Options(
      headers: {
        if (_token != null) 'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  Future<AuthSessionDto> login({required String email, required String password, required AppRole role}) async {
    return _request(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password, 'role': role.label},
        options: _options(),
      );
      return AuthSessionDto.fromJson(response.data ?? <String, dynamic>{});
    });
  }

  Future<AppUser> fetchCurrentUser() async {
    return _request(() async {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me', options: _options());
      return AppUser.fromJson(response.data?['user'] as Map<String, dynamic>? ?? <String, dynamic>{});
    });
  }

  Future<AppUser> fetchProfile() async {
    return _request(() async {
      final response = await _dio.get<Map<String, dynamic>>('/profile', options: _options());
      return AppUser.fromJson(response.data?['user'] as Map<String, dynamic>? ?? <String, dynamic>{});
    });
  }

  Future<AppUser> updateProfile({required String name, String? phoneNumber, String? address}) async {
    return _request(() async {
      final response = await _dio.put<Map<String, dynamic>>(
        '/profile',
        data: {'name': name, 'phoneNumber': phoneNumber, 'address': address},
        options: _options(),
      );
      return AppUser.fromJson(response.data?['user'] as Map<String, dynamic>? ?? <String, dynamic>{});
    });
  }

  Future<AuthSessionDto> register({required String name, required String email, required String password, required AppRole role}) async {
    return _request(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password, 'role': role.label},
        options: _options(),
      );
      return AuthSessionDto.fromJson(response.data ?? <String, dynamic>{});
    });
  }

  Future<List<JobPost>> fetchJobs() async {
    return _request(() async {
      final response = await _dio.get<Map<String, dynamic>>('/jobs', options: _options());
      final items = (response.data?['jobs'] as List<dynamic>? ?? const <dynamic>[]).cast<Map<String, dynamic>>();
      return items.map(JobPost.fromJson).toList();
    });
  }

  Future<List<JobApplication>> fetchStudentApplications({required String studentId}) async {
    return _request(() async {
      final response = await _dio.get<Map<String, dynamic>>('/applications/student/$studentId', options: _options());
      final items = (response.data?['applications'] as List<dynamic>? ?? const <dynamic>[]).cast<Map<String, dynamic>>();
      return items.map(JobApplication.fromJson).toList();
    });
  }

  Future<JobPost> createJob({required Map<String, dynamic> payload}) async {
    return _request(() async {
      final response = await _dio.post<Map<String, dynamic>>('/jobs', data: payload, options: _options());
      return JobPost.fromJson(response.data?['job'] as Map<String, dynamic>? ?? <String, dynamic>{});
    });
  }

  Future<JobApplication> applyToJob({required String jobId}) async {
    return _request(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/applications/apply',
        data: {'jobId': jobId},
        options: _options(),
      );
      return JobApplication.fromJson(response.data?['application'] as Map<String, dynamic>? ?? <String, dynamic>{});
    });
  }

  Future<List<JobApplication>> fetchApplicants({required String jobId}) async {
    return _request(() async {
      final response = await _dio.get<Map<String, dynamic>>('/jobs/$jobId/applicants', options: _options());
      final items = (response.data?['applicants'] as List<dynamic>? ?? const <dynamic>[]).cast<Map<String, dynamic>>();
      return items.map(JobApplication.fromJson).toList();
    });
  }

  Future<JobApplication> updateApplicationStatus({required String applicationId, required String status}) async {
    return _request(() async {
      final response = await _dio.put<Map<String, dynamic>>(
        '/applications/status',
        data: {'applicationId': applicationId, 'status': status},
        options: _options(),
      );
      return JobApplication.fromJson(response.data?['application'] as Map<String, dynamic>? ?? <String, dynamic>{});
    });
  }

  Future<Map<String, dynamic>> fetchAdminStats() async {
    return _request(() async {
      final response = await _dio.get(
        '/admin/stats',
        options: _options(),
      );
      return response.data as Map<String, dynamic>;
    });
  }

  Future<List<Map<String, dynamic>>> fetchAdminUsers({String? search, String? role}) async {
    return _request(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/admin/users',
        queryParameters: <String, dynamic>{
          if (search != null && search.isNotEmpty) 'search': search,
          if (role != null && role.isNotEmpty) 'role': role,
        },
        options: _options(),
      );
      return (response.data?['users'] as List<dynamic>? ?? const <dynamic>[]).cast<Map<String, dynamic>>();
    });
  }

  Future<List<Map<String, dynamic>>> fetchAdminJobs({String? search}) async {
    return _request(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/admin/jobs',
        queryParameters: <String, dynamic>{if (search != null && search.isNotEmpty) 'search': search},
        options: _options(),
      );
      return (response.data?['jobs'] as List<dynamic>? ?? const <dynamic>[]).cast<Map<String, dynamic>>();
    });
  }

  Future<List<Map<String, dynamic>>> fetchAdminApplications({String? search, String? status}) async {
    return _request(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/admin/applications',
        queryParameters: <String, dynamic>{
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
        },
        options: _options(),
      );
      return (response.data?['applications'] as List<dynamic>? ?? const <dynamic>[]).cast<Map<String, dynamic>>();
    });
  }

  Future<void> deleteAdminUser(String id) async {
    await _request(() async {
      await _dio.delete<void>('/admin/users/$id', options: _options());
    });
  }

  Future<void> deleteAdminJob(String id) async {
    await _request(() async {
      await _dio.delete<void>('/admin/jobs/$id', options: _options());
    });
  }

  Future<void> deleteAdminApplication(String id) async {
    await _request(() async {
      await _dio.delete<void>('/admin/applications/$id', options: _options());
    });
  }

}

class AuthSessionDto {
  AuthSessionDto({required this.token, required this.user});

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      token: json['token'] as String? ?? '',
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>? ?? <String, dynamic>{}),
    );
  }

  final String token;
  final AppUser user;
}
