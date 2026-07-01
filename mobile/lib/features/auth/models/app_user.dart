enum AppRole {
  student,
  caterer,
  admin,
}
extension AppRoleX on AppRole {
  String get label {
    switch (this) {
      case AppRole.student:
        return 'STUDENT';
      case AppRole.caterer:
        return 'CATERER';
      case AppRole.admin:
        return 'ADMIN';
    }
  }

  String get displayName {
    switch (this) {
      case AppRole.student:
        return 'Student';
      case AppRole.caterer:
        return 'Caterer';
      case AppRole.admin:
        return 'Admin';
    }
  }

  static AppRole fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'STUDENT':
        return AppRole.student;

      case 'CATERER':
        return AppRole.caterer;

      case 'ADMIN':
        return AppRole.admin;

      default:
        return AppRole.student;
    }
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.address,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: AppRoleX.fromApi((json['role'] as String? ?? 'STUDENT')),
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      createdAt: json['createdAt'] == null ? null : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  final String id;
  final String name;
  final String email;
  final AppRole role;
  final String? phoneNumber;
  final String? address;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'role': role.label,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AppUser user;
}
