/// Roles supported across the unified authentication gateway
enum UserRole {
  admin,
  teacher,
  parent,
  student;

  static UserRole fromString(String? role) {
    switch (role?.trim().toUpperCase()) {
      case 'ADMIN':
      case 'SCHOOL_MANAGER':
        return UserRole.admin;
      case 'TEACHER':
      case 'STAFF':
        return UserRole.teacher;
      case 'PARENT':
      case 'GUARDIAN':
        return UserRole.parent;
      case 'STUDENT':
      case 'PUPIL':
        return UserRole.student;
      default:
        throw ArgumentError('Unrecognized UserRole: $role');
    }
  }

  String toFormattedString() {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.teacher:
        return 'TEACHER';
      case UserRole.parent:
        return 'PARENT';
      case UserRole.student:
        return 'STUDENT';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'School Manager';
      case UserRole.teacher:
        return 'Teacher & Faculty';
      case UserRole.parent:
        return 'Parent & Guardian';
      case UserRole.student:
        return 'Student';
    }
  }

  String get defaultRoute {
    switch (this) {
      case UserRole.admin:
        return '/admin';
      case UserRole.teacher:
        return '/teacher';
      case UserRole.parent:
        return '/parent';
      case UserRole.student:
        return '/student';
    }
  }
}
