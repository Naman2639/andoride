import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_erp/main.dart';
import 'package:school_erp/app.dart';
import 'package:school_erp/core/router/app_router.dart';
import 'package:school_erp/core/services/assignment_sync_service.dart';
import 'package:school_erp/features/auth/presentation/views/login_screen.dart';
import 'package:school_erp/features/auth/presentation/views/otp_verification_screen.dart';
import 'package:school_erp/features/admin_portal/presentation/views/admin_dashboard_screen.dart';
import 'package:school_erp/features/admin_portal/presentation/views/admin_shell_screen.dart';
import 'package:school_erp/features/teacher_portal/presentation/views/teacher_dashboard_screen.dart';
import 'package:school_erp/features/teacher_portal/presentation/views/teacher_shell_screen.dart';
import 'package:school_erp/features/student_portal/presentation/views/student_dashboard_screen.dart';
import 'package:school_erp/features/student_portal/presentation/views/student_shell_screen.dart';
import 'package:school_erp/features/parent_portal/presentation/views/parent_dashboard_screen.dart';
import 'package:school_erp/features/parent_portal/presentation/views/parent_shell_screen.dart';

void main() {
  test('All screens and services compile and initialize without syntax errors', () {
    // Verify services
    final syncService = AssignmentSyncService();
    expect(syncService, isNotNull);
    expect(syncService.assignmentsNotifier.value.isNotEmpty, isTrue);

    // Verify widgets instantiate cleanly
    expect(const StudentDashboardScreen(), isA<Widget>());
    expect(const ParentDashboardScreen(), isA<Widget>());
    expect(const TeacherDashboardScreen(), isA<Widget>());
    expect(const AdminDashboardScreen(), isA<Widget>());
    expect(const LoginScreen(), isA<Widget>());
    expect(const OtpVerificationScreen(identifier: 'test@school.edu'), isA<Widget>());
    expect(const StudentShellScreen(child: SizedBox()), isA<Widget>());
    expect(const ParentShellScreen(child: SizedBox()), isA<Widget>());
    expect(const TeacherShellScreen(child: SizedBox()), isA<Widget>());
    expect(const AdminShellScreen(child: SizedBox()), isA<Widget>());
  });
}
