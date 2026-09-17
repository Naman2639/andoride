import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

/// Central dynamic registry managing registered Teachers, Students, and System Users.
/// Persists newly enrolled IDs so they can sign in with their Google accounts immediately.
class UserRegistryService {
  final SecureStorageService _storageService;

  UserRegistryService({required SecureStorageService storageService})
      : _storageService = storageService;

  /// Default baseline accounts pre-configured in the school system
  static final List<UserModel> _defaultUsers = [
    const UserModel(
      id: 'USR_ADMIN_01',
      name: 'Dr. Robert Vance',
      emailOrPhone: 'admin.school@gmail.com',
      role: UserRole.admin,
      designation: 'School Director & Administrator',
      assignedClasses: ['Governance', 'All Wings'],
    ),
    const UserModel(
      id: 'USR_TEACHER_01',
      name: 'Sarah Jenkins, M.Sc.',
      emailOrPhone: 'teacher.sarah@gmail.com',
      role: UserRole.teacher,
      designation: 'Class 10-A Head & Math Faculty',
      assignedClasses: ['Class 10-A', 'Class 9-B'],
    ),
    const UserModel(
      id: 'USR_STUDENT_01',
      name: 'Alex Rivera',
      emailOrPhone: 'student.alex@gmail.com',
      role: UserRole.student,
      designation: 'Roll No: 10A-14 • Class 10-A',
      assignedClasses: ['Class 10-A'],
    ),
    const UserModel(
      id: 'USR_PARENT_01',
      name: 'Michael & Elena Scott',
      emailOrPhone: 'parent.scott@gmail.com',
      role: UserRole.parent,
      designation: 'Guardian of Liam Scott (10-A)',
      assignedClasses: ['Class 10-A'],
      studentIds: ['USR_STUDENT_01'],
    ),
  ];

  /// Get list of pre-configured Google demo accounts for fast testing
  List<UserModel> getDemoGoogleProfiles() => List.unmodifiable(_defaultUsers);

  /// Find user by Google email (checks default users + custom registered users)
  Future<UserModel?> findByGoogleEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Check default users and their accepted aliases
    for (final user in _defaultUsers) {
      final userEmail = user.emailOrPhone.toLowerCase();
      if (userEmail == cleanEmail) return user;
      // Allow legacy/alias formats e.g. admin@school.org
      if (cleanEmail == 'admin@school.org' && user.role == UserRole.admin) return user;
      if (cleanEmail == 'teacher@school.org' && user.role == UserRole.teacher) return user;
      if (cleanEmail == 'student@school.org' && user.role == UserRole.student) return user;
      if (cleanEmail == 'parent@school.org' && user.role == UserRole.parent) return user;
    }

    // 2. Check registered custom Teachers
    final customTeachers = await getCustomTeachers();
    for (final teacher in customTeachers) {
      if (teacher.emailOrPhone.toLowerCase() == cleanEmail) {
        return teacher;
      }
    }

    // 3. Check registered custom Students
    final customStudents = await getCustomStudents();
    for (final student in customStudents) {
      if (student.emailOrPhone.toLowerCase() == cleanEmail) {
        return student;
      }
    }

    return null;
  }

  // ==========================================
  // TEACHER MANAGEMENT (Admin actions)
  // ==========================================

  /// Fetch all teachers (default + custom created by admin)
  Future<List<UserModel>> getAllTeachers() async {
    final custom = await getCustomTeachers();
    final defaults = _defaultUsers.where((u) => u.role == UserRole.teacher).toList();
    return [...defaults, ...custom];
  }

  /// Read custom teachers from persistent storage
  Future<List<UserModel>> getCustomTeachers() async {
    try {
      final jsonStr = await _storageService.getCustomData(AppConstants.keyCustomTeachers);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Admin creates a new Teacher ID with Google account authorization
  Future<UserModel> registerNewTeacher({
    required String name,
    required String googleEmail,
    required String designation,
    required List<String> assignedClasses,
    String? employeeId,
  }) async {
    final existing = await findByGoogleEmail(googleEmail);
    if (existing != null) {
      throw Exception('A user with Google account "$googleEmail" is already registered as ${existing.role.displayName}.');
    }

    final id = employeeId ?? 'TCH_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final newTeacher = UserModel(
      id: id,
      name: name.trim(),
      emailOrPhone: googleEmail.trim().toLowerCase(),
      role: UserRole.teacher,
      designation: designation.trim().isNotEmpty ? designation.trim() : 'Faculty Member',
      assignedClasses: assignedClasses.isNotEmpty ? assignedClasses : ['Class 10-A'],
    );

    final currentTeachers = await getCustomTeachers();
    currentTeachers.add(newTeacher);
    await _saveCustomTeachers(currentTeachers);

    return newTeacher;
  }

  /// Remove a custom teacher by ID
  Future<void> deleteTeacher(String teacherId) async {
    final currentTeachers = await getCustomTeachers();
    currentTeachers.removeWhere((t) => t.id == teacherId);
    await _saveCustomTeachers(currentTeachers);
  }

  Future<void> _saveCustomTeachers(List<UserModel> teachers) async {
    final rawList = teachers.map((t) => t.toJson()).toList();
    await _storageService.saveCustomData(AppConstants.keyCustomTeachers, jsonEncode(rawList));
  }

  // ==========================================
  // STUDENT MANAGEMENT (Teacher actions)
  // ==========================================

  /// Fetch all students (default + custom created by teachers)
  Future<List<UserModel>> getAllStudents({String? classFilter}) async {
    final custom = await getCustomStudents();
    final defaults = _defaultUsers.where((u) => u.role == UserRole.student).toList();
    final all = [...defaults, ...custom];

    if (classFilter != null && classFilter.isNotEmpty) {
      return all.where((s) => s.assignedClasses.contains(classFilter)).toList();
    }
    return all;
  }

  /// Read custom students from persistent storage
  Future<List<UserModel>> getCustomStudents() async {
    try {
      final jsonStr = await _storageService.getCustomData(AppConstants.keyCustomStudents);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Teacher creates a new Student ID with Google account authorization
  Future<UserModel> registerNewStudent({
    required String name,
    required String googleEmail,
    required String rollNumber,
    required String className,
    String? guardianName,
  }) async {
    final existing = await findByGoogleEmail(googleEmail);
    if (existing != null) {
      throw Exception('A user with Google account "$googleEmail" is already registered as ${existing.role.displayName}.');
    }

    final id = rollNumber.isNotEmpty
        ? rollNumber.trim()
        : 'STU_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final newStudent = UserModel(
      id: id,
      name: name.trim(),
      emailOrPhone: googleEmail.trim().toLowerCase(),
      role: UserRole.student,
      designation: 'Roll No: $id • $className',
      assignedClasses: [className.trim().isNotEmpty ? className.trim() : 'Class 10-A'],
    );

    final currentStudents = await getCustomStudents();
    currentStudents.add(newStudent);
    await _saveCustomStudents(currentStudents);

    return newStudent;
  }

  /// Remove a custom student by ID
  Future<void> deleteStudent(String studentId) async {
    final currentStudents = await getCustomStudents();
    currentStudents.removeWhere((s) => s.id == studentId);
    await _saveCustomStudents(currentStudents);
  }

  Future<void> _saveCustomStudents(List<UserModel> students) async {
    final rawList = students.map((s) => s.toJson()).toList();
    await _storageService.saveCustomData(AppConstants.keyCustomStudents, jsonEncode(rawList));
  }
}
