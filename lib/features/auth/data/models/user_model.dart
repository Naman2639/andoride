import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';

/// Data model for User with JSON serialization/deserialization
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.emailOrPhone,
    required super.role,
    super.profilePhotoUrl,
    super.designation,
    super.assignedClasses,
    super.studentIds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emailOrPhone: json['emailOrPhone'] as String? ?? json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      designation: json['designation'] as String?,
      assignedClasses: (json['assignedClasses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      studentIds: (json['studentIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emailOrPhone': emailOrPhone,
      'role': role.toFormattedString(),
      'profilePhotoUrl': profilePhotoUrl,
      'designation': designation,
      'assignedClasses': assignedClasses,
      'studentIds': studentIds,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      emailOrPhone: user.emailOrPhone,
      role: user.role,
      profilePhotoUrl: user.profilePhotoUrl,
      designation: user.designation,
      assignedClasses: user.assignedClasses,
      studentIds: user.studentIds,
    );
  }
}
