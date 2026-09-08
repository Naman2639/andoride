/// Roles supported across the unified authentication gateway
enum UserRole {
  admin,
  teacher,
  parent;

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
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'School Manager';
      case UserRole.teacher:
        return 'Teacher & Staff';
      case UserRole.parent:
        return 'Parent & Guardian';
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
    }
  }
}
