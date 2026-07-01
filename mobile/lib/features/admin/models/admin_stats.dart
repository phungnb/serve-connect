class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.students,
    required this.caterers,
    required this.admins,
    required this.jobs,
    required this.applications,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] ?? 0,
      students: json['students'] ?? 0,
      caterers: json['caterers'] ?? 0,
      admins: json['admins'] ?? 0,
      jobs: json['jobs'] ?? 0,
      applications: json['applications'] ?? 0,
    );
  }

  final int totalUsers;
  final int students;
  final int caterers;
  final int admins;
  final int jobs;
  final int applications;
}

class AdminUserRecord {
  const AdminUserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phoneNumber,
    required this.address,
    required this.createdAt,
  });

  factory AdminUserRecord.fromJson(Map<String, dynamic> json) {
    return AdminUserRecord(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'STUDENT',
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final String id;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? address;
  final DateTime createdAt;
}

class AdminJobRecord {
  const AdminJobRecord({
    required this.id,
    required this.title,
    required this.locationString,
    required this.status,
    required this.catererName,
    required this.applicationsCount,
    required this.createdAt,
  });

  factory AdminJobRecord.fromJson(Map<String, dynamic> json) {
    return AdminJobRecord(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      locationString: json['location_string'] as String? ?? json['locationString'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      catererName: json['caterer_name'] as String? ?? json['catererName'] as String? ?? '',
      applicationsCount: int.tryParse(json['applications_count']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final String id;
  final String title;
  final String locationString;
  final String status;
  final String catererName;
  final int applicationsCount;
  final DateTime createdAt;
}

class AdminApplicationRecord {
  const AdminApplicationRecord({
    required this.id,
    required this.jobTitle,
    required this.studentName,
    required this.studentEmail,
    required this.status,
    required this.createdAt,
  });

  factory AdminApplicationRecord.fromJson(Map<String, dynamic> json) {
    return AdminApplicationRecord(
      id: json['id'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? json['jobTitle'] as String? ?? '',
      studentName: json['student_name'] as String? ?? json['studentName'] as String? ?? '',
      studentEmail: json['student_email'] as String? ?? json['studentEmail'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final String id;
  final String jobTitle;
  final String studentName;
  final String studentEmail;
  final String status;
  final DateTime createdAt;
}