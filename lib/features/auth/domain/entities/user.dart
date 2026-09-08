import 'package:equatable/equatable.dart';
import 'user_role.dart';

/// Clean Domain representation of an authenticated user
class User extends Equatable {
  final String id;
  final String name;
  final String emailOrPhone;
  final UserRole role;
  final String? profilePhotoUrl;
  final String? designation; // e.g. "Senior Mathematics Teacher", "Principal"
  final List<String> assignedClasses; // e.g. ["Class 10-A", "Class 9-B"]
  final List<String> studentIds; // Linked wards for Parents

  const User({
    required this.id,
    required this.name,
    required this.emailOrPhone,
    required this.role,
    this.profilePhotoUrl,
    this.designation,
    this.assignedClasses = const [],
    this.studentIds = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        emailOrPhone,
        role,
        profilePhotoUrl,
        designation,
        assignedClasses,
        studentIds,
      ];
}
