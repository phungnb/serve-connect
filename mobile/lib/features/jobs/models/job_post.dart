class JobPost {
  const JobPost({
    required this.id,
    required this.catererId,
    required this.catererName,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.salaryAmount,
    required this.workersNeeded,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['id'] as String? ?? '',
      catererId: json['catererId'] as String? ?? json['caterer_id'] as String? ?? '',
      catererName: json['catererName'] as String? ?? json['caterer_name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      eventDate: DateTime.tryParse(_stringValue(json['eventDate']) ?? _stringValue(json['event_date']) ?? '') ?? DateTime.now(),
      startTime: json['startTime'] as String? ?? json['start_time'] as String? ?? '00:00',
      endTime: json['endTime'] as String? ?? json['end_time'] as String? ?? '00:00',
      salaryAmount: _doubleValue(json['salaryAmount']) ?? _doubleValue(json['salary_amount']) ?? 0,
      workersNeeded: _intValue(json['workersNeeded']) ?? _intValue(json['workers_needed']) ?? 0,
      location: json['location'] as String? ?? json['locationString'] as String? ?? json['location_string'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      createdAt: DateTime.tryParse(_stringValue(json['createdAt']) ?? _stringValue(json['created_at']) ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(_stringValue(json['updatedAt']) ?? _stringValue(json['updated_at']) ?? '') ?? DateTime.now(),
    );
  }

  final String id;
  final String catererId;
  final String catererName;
  final String title;
  final String description;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final double salaryAmount;
  final int workersNeeded;
  final String location;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  static String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    return value.toString();
  }

  static double? _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static int? _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}

class CreateJobDraft {
  const CreateJobDraft({
    required this.title,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.salaryAmount,
    required this.workersNeeded,
    required this.location,
  });

  final String title;
  final String description;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final double salaryAmount;
  final int workersNeeded;
  final String location;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'salaryAmount': salaryAmount,
      'workersNeeded': workersNeeded,
      'locationString': location,
    };
  }
}
