class JobApplication {
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] as String? ?? json['applicationId'] as String? ?? json['application_id'] as String? ?? '',
      jobId: json['jobId'] as String? ?? json['job_id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? json['student_id'] as String? ?? '',
      studentName: json['studentName'] as String? ?? json['student_name'] as String? ?? 'Applicant',
      studentEmail: json['studentEmail'] as String? ?? json['student_email'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final String id;
  final String jobId;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
}
