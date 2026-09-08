import 'package:flutter_test/flutter_test.dart';
import 'package:school_erp/core/router/route_paths.dart';
import 'package:school_erp/features/auth/domain/entities/user.dart';
import 'package:school_erp/features/auth/domain/entities/user_role.dart';
import 'package:school_erp/features/auth/presentation/bloc/auth_state.dart';

/// Pure function replicating the redirect guard logic from AppRouter
/// to perform fast, deterministic RBAC assertion tests.
String? evaluateRedirect({
  required AuthState authState,
  required String matchedLocation,
}) {
  if (authState is AuthInitial) {
    return null;
  }

  final isAuthenticated = authState is Authenticated;
  final isLoggingIn = matchedLocation == RoutePaths.login ||
      matchedLocation == RoutePaths.otp;

  // Unauthenticated Guard
  if (!isAuthenticated) {
    if (isLoggingIn) return null;

    if (authState is Unauthenticated && authState.isSessionTimeout) {
      return '${RoutePaths.login}?reason=session_timeout';
    }

    return RoutePaths.login;
  }

  // Authenticated - Extract role
  final userRole = authState.user.role;

  // If user is visiting login/otp or splash, redirect to authorized portal
  if (isLoggingIn || matchedLocation == RoutePaths.splash) {
    return userRole.defaultRoute;
  }

  // Strict Role Boundary Guards
  final isAdminRoute = matchedLocation.startsWith('/admin');
  final isTeacherRoute = matchedLocation.startsWith('/teacher');
  final isParentRoute = matchedLocation.startsWith('/parent');

  if (isAdminRoute && userRole != UserRole.admin) {
    return userRole.defaultRoute;
  }

  if (isTeacherRoute && userRole != UserRole.teacher) {
    return userRole.defaultRoute;
  }

  if (isParentRoute && userRole != UserRole.parent) {
    return userRole.defaultRoute;
  }

  return null; // Navigation authorized
}

void main() {
  group('GoRouter RBAC Redirect Guards Matrix', () {
    const adminUser = User(
      id: 'A1',
      name: 'Admin',
      emailOrPhone: 'admin@school.org',
      role: UserRole.admin,
    );

    const teacherUser = User(
      id: 'T1',
      name: 'Teacher',
      emailOrPhone: 'teacher@school.org',
      role: UserRole.teacher,
    );

    const parentUser = User(
      id: 'P1',
      name: 'Parent',
      emailOrPhone: 'parent@school.org',
      role: UserRole.parent,
    );

    test('Unauthenticated user requesting /admin is redirected to /login', () {
      final redirect = evaluateRedirect(
        authState: const Unauthenticated(),
        matchedLocation: '/admin',
      );
      expect(redirect, equals(RoutePaths.login));
    });

    test('Unauthenticated user requesting /teacher is redirected to /login', () {
      final redirect = evaluateRedirect(
        authState: const Unauthenticated(),
        matchedLocation: '/teacher',
      );
      expect(redirect, equals(RoutePaths.login));
    });

    test('Unauthenticated user requesting /login is permitted (returns null)', () {
      final redirect = evaluateRedirect(
        authState: const Unauthenticated(),
        matchedLocation: RoutePaths.login,
      );
      expect(redirect, isNull);
    });

    test('Session timeout redirects to /login with query parameter', () {
      final redirect = evaluateRedirect(
        authState: const Unauthenticated(isSessionTimeout: true),
        matchedLocation: '/admin',
      );
      expect(redirect, equals('${RoutePaths.login}?reason=session_timeout'));
    });

    test('Authenticated ADMIN visiting /login is redirected to /admin', () {
      final redirect = evaluateRedirect(
        authState: const Authenticated(user: adminUser),
        matchedLocation: RoutePaths.login,
      );
      expect(redirect, equals(RoutePaths.adminDashboard));
    });

    test('Authenticated TEACHER visiting /login is redirected to /teacher', () {
      final redirect = evaluateRedirect(
        authState: const Authenticated(user: teacherUser),
        matchedLocation: RoutePaths.login,
      );
      expect(redirect, equals(RoutePaths.teacherDashboard));
    });

    test('Authenticated PARENT visiting /login is redirected to /parent', () {
      final redirect = evaluateRedirect(
        authState: const Authenticated(user: parentUser),
        matchedLocation: RoutePaths.login,
      );
      expect(redirect, equals(RoutePaths.parentDashboard));
    });

    test('Anti-Privilege Escalation: PARENT trying to access /admin is bounced to /parent', () {
      final redirect = evaluateRedirect(
        authState: const Authenticated(user: parentUser),
        matchedLocation: '/admin',
      );
      expect(redirect, equals(RoutePaths.parentDashboard));
    });

    test('Anti-Privilege Escalation: TEACHER trying to access /admin is bounced to /teacher', () {
      final redirect = evaluateRedirect(
        authState: const Authenticated(user: teacherUser),
        matchedLocation: '/admin',
      );
      expect(redirect, equals(RoutePaths.teacherDashboard));
    });

    test('Anti-Privilege Escalation: ADMIN trying to access /parent is rebounded to /admin', () {
      final redirect = evaluateRedirect(
        authState: const Authenticated(user: adminUser),
        matchedLocation: '/parent',
      );
      expect(redirect, equals(RoutePaths.adminDashboard));
    });

    test('Authenticated user accessing their own portal is permitted (returns null)', () {
      expect(
        evaluateRedirect(
          authState: const Authenticated(user: adminUser),
          matchedLocation: '/admin',
        ),
        isNull,
      );

      expect(
        evaluateRedirect(
          authState: const Authenticated(user: teacherUser),
          matchedLocation: '/teacher',
        ),
        isNull,
      );

      expect(
        evaluateRedirect(
          authState: const Authenticated(user: parentUser),
          matchedLocation: '/parent',
        ),
        isNull,
      );
    });
  });
}
