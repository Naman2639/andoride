import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin_portal/presentation/views/admin_dashboard_screen.dart';
import '../../features/admin_portal/presentation/views/admin_shell_screen.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/otp_verification_screen.dart';
import '../../features/parent_portal/presentation/views/parent_dashboard_screen.dart';
import '../../features/parent_portal/presentation/views/parent_shell_screen.dart';
import '../../features/teacher_portal/presentation/views/teacher_dashboard_screen.dart';
import '../../features/teacher_portal/presentation/views/teacher_shell_screen.dart';
import 'route_paths.dart';
import 'router_refresh_stream.dart';

/// Global Navigator keys for root and nested shells
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> adminNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'admin');
final GlobalKey<NavigatorState> teacherNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'teacher');
final GlobalKey<NavigatorState> parentNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'parent');

/// Centralized declarative GoRouter configuration with strict RBAC guards
class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RoutePaths.login,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final matchedLocation = state.matchedLocation;

        // 1. Initial / Loading state check
        if (authState is AuthInitial) {
          return null;
        }

        final isAuthenticated = authState is Authenticated;
        final isLoggingIn = matchedLocation == RoutePaths.login ||
            matchedLocation == RoutePaths.otp;

        // 2. Unauthenticated Guard
        if (!isAuthenticated) {
          // Allow access to login and OTP verification screens
          if (isLoggingIn) return null;

          // If session timed out, preserve reason in query parameter
          if (authState is Unauthenticated && authState.isSessionTimeout) {
            return '${RoutePaths.login}?reason=session_timeout';
          }

          // Any other route attempt redirects to login gateway
          return RoutePaths.login;
        }

        // 3. Authenticated - Extract role
        final userRole = authState.user.role;

        // If user is currently trying to visit login/otp, bounce to their authorized portal
        if (isLoggingIn || matchedLocation == RoutePaths.splash) {
          return userRole.defaultRoute;
        }

        // 4. Strict Role-Based Boundary Guards (Anti-Privilege Escalation)
        // Ensure no user can access another role's portal through deep linking or URL tampering
        final isAdminRoute = matchedLocation.startsWith('/admin');
        final isTeacherRoute = matchedLocation.startsWith('/teacher');
        final isParentRoute = matchedLocation.startsWith('/parent');

        if (isAdminRoute && userRole != UserRole.admin) {
          // Unauthorized access attempt to Admin portal
          return userRole.defaultRoute;
        }

        if (isTeacherRoute && userRole != UserRole.teacher) {
          // Unauthorized access attempt to Teacher portal
          return userRole.defaultRoute;
        }

        if (isParentRoute && userRole != UserRole.parent) {
          // Unauthorized access attempt to Parent portal
          return userRole.defaultRoute;
        }

        // Access authorized
        return null;
      },
      routes: [
        // --- Authentication Gateway Routes ---
        GoRoute(
          path: RoutePaths.login,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final reason = state.uri.queryParameters['reason'];
            final message = reason == 'session_timeout'
                ? 'Your administrative session timed out due to inactivity.'
                : null;
            return LoginScreen(sessionMessage: message);
          },
        ),
        GoRoute(
          path: RoutePaths.otp,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final identifier = state.uri.queryParameters['identifier'] ?? '';
            return OtpVerificationScreen(identifier: identifier);
          },
        ),

        // --- Admin Portal Shell Route ---
        ShellRoute(
          navigatorKey: adminNavigatorKey,
          builder: (context, state, child) => AdminShellScreen(child: child),
          routes: [
            GoRoute(
              path: RoutePaths.adminDashboard,
              builder: (context, state) => const AdminDashboardScreen(),
            ),
          ],
        ),

        // --- Teacher Portal Shell Route ---
        ShellRoute(
          navigatorKey: teacherNavigatorKey,
          builder: (context, state, child) => TeacherShellScreen(child: child),
          routes: [
            GoRoute(
              path: RoutePaths.teacherDashboard,
              builder: (context, state) => const TeacherDashboardScreen(),
            ),
          ],
        ),

        // --- Parent Portal Shell Route ---
        ShellRoute(
          navigatorKey: parentNavigatorKey,
          builder: (context, state, child) => ParentShellScreen(child: child),
          routes: [
            GoRoute(
              path: RoutePaths.parentDashboard,
              builder: (context, state) => const ParentDashboardScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
              const SizedBox(height: 16),
              Text(
                'Route Not Found: ${state.matchedLocation}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.login),
                child: const Text('Return to Gateway'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
