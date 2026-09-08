import 'package:flutter_test/flutter_test.dart';
import 'package:school_erp/core/constants/app_constants.dart';
import 'package:school_erp/core/session/session_manager.dart';
import 'package:school_erp/core/storage/secure_storage_service.dart';
import 'package:school_erp/features/auth/domain/entities/user_role.dart';

class FakeSecureStorageService implements SecureStorageService {
  DateTime? lastActive;

  @override
  Future<void> recordActiveTimestamp() async {
    lastActive = DateTime.now();
  }

  @override
  Future<DateTime?> getLastActiveTimestamp() async {
    return lastActive;
  }

  // Stubs for interface compliance
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SessionManager Inactivity Policies', () {
    late FakeSecureStorageService fakeStorage;
    late SessionManager sessionManager;

    setUp(() {
      fakeStorage = FakeSecureStorageService();
      sessionManager = SessionManager(storageService: fakeStorage);
    });

    test('enforces 15-minute timeout for ADMIN role to protect sensitive records', () {
      final duration = sessionManager.getTimeoutForRole(UserRole.admin);
      expect(duration, equals(AppConstants.adminSessionTimeout));
      expect(duration.inMinutes, equals(15));
    });

    test('enforces 8-hour shift timeout for TEACHER role', () {
      final duration = sessionManager.getTimeoutForRole(UserRole.teacher);
      expect(duration, equals(AppConstants.teacherSessionTimeout));
      expect(duration.inHours, equals(8));
    });

    test('enforces 30-day persistent mobile timeout for PARENT role', () {
      final duration = sessionManager.getTimeoutForRole(UserRole.parent);
      expect(duration, equals(AppConstants.parentSessionTimeout));
      expect(duration.inDays, equals(30));
    });

    test('isSessionValid returns true if activity is within threshold', () async {
      fakeStorage.lastActive = DateTime.now().subtract(const Duration(minutes: 5));
      final isValid = await sessionManager.isSessionValid(UserRole.admin);
      expect(isValid, isTrue);
    });

    test('isSessionValid returns false if Admin inactivity exceeds 15 minutes', () async {
      fakeStorage.lastActive = DateTime.now().subtract(const Duration(minutes: 16));
      final isValid = await sessionManager.isSessionValid(UserRole.admin);
      expect(isValid, isFalse);
    });

    test('Parent session remains valid after 2 hours of inactivity', () async {
      fakeStorage.lastActive = DateTime.now().subtract(const Duration(hours: 2));
      final isValid = await sessionManager.isSessionValid(UserRole.parent);
      expect(isValid, isTrue);
    });
  });
}
