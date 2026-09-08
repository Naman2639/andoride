import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_erp/core/session/session_manager.dart';
import 'package:school_erp/core/storage/secure_storage_service.dart';
import 'package:school_erp/features/auth/domain/entities/user.dart';
import 'package:school_erp/features/auth/domain/entities/user_role.dart';
import 'package:school_erp/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_erp/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_erp/features/auth/presentation/bloc/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  User? mockUser;
  bool shouldFail = false;

  @override
  Future<User?> checkAuthStatus() async {
    if (shouldFail) throw Exception('Storage error');
    return mockUser;
  }

  @override
  Future<User> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    if (shouldFail) throw Exception('Invalid credentials');
    return mockUser ??
        const User(
          id: 'USR_1',
          name: 'Admin User',
          emailOrPhone: 'admin@school.org',
          role: UserRole.admin,
        );
  }

  @override
  Future<void> requestOtp({required String identifier}) async {}

  @override
  Future<User> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    return mockUser ??
        const User(
          id: 'USR_2',
          name: 'Parent User',
          emailOrPhone: 'parent@school.org',
          role: UserRole.parent,
        );
  }

  @override
  Future<bool> isSessionValid(UserRole role) async => true;

  @override
  Future<void> logout() async {
    mockUser = null;
  }
}

class FakeSessionManager extends SessionManager {
  FakeSessionManager() : super(storageService: FakeSecureStorageService());

  @override
  Future<void> recordUserActivity() async {}

  @override
  Future<void> startSession(UserRole role) async {}

  @override
  void stopSession() {}
}

class FakeSecureStorageService implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AuthBloc Lifecycle & State Transitions', () {
    late FakeAuthRepository authRepository;
    late FakeSessionManager sessionManager;

    const testAdminUser = User(
      id: 'USR_ADMIN_01',
      name: 'Dr. Robert Vance',
      emailOrPhone: 'admin@school.org',
      role: UserRole.admin,
    );

    setUp(() {
      authRepository = FakeAuthRepository();
      sessionManager = FakeSessionManager();
    });

    test('initial state is AuthInitial', () {
      final bloc = AuthBloc(
        authRepository: authRepository,
        sessionManager: sessionManager,
      );
      expect(bloc.state, equals(const AuthInitial()));
      bloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on AppStarted when no session cached',
      build: () => AuthBloc(
        authRepository: authRepository,
        sessionManager: sessionManager,
      ),
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        const AuthLoading(message: 'Verifying session...'),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on AppStarted when valid session cached',
      setUp: () {
        authRepository.mockUser = testAdminUser;
      },
      build: () => AuthBloc(
        authRepository: authRepository,
        sessionManager: sessionManager,
      ),
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        const AuthLoading(message: 'Verifying session...'),
        const Authenticated(user: testAdminUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on LoginSubmitted success',
      setUp: () {
        authRepository.mockUser = testAdminUser;
      },
      build: () => AuthBloc(
        authRepository: authRepository,
        sessionManager: sessionManager,
      ),
      act: (bloc) => bloc.add(const LoginSubmitted(
        identifier: 'admin@school.org',
        password: 'password123',
      )),
      expect: () => [
        const AuthLoading(message: 'Authenticating credentials...'),
        const Authenticated(user: testAdminUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits Unauthenticated with isSessionTimeout=true on SessionTimedOut',
      build: () => AuthBloc(
        authRepository: authRepository,
        sessionManager: sessionManager,
      ),
      act: (bloc) => bloc.add(const SessionTimedOut()),
      expect: () => [
        const Unauthenticated(
          isSessionTimeout: true,
          message: 'Administrative session timed out due to inactivity to protect records.',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on LogoutRequested',
      build: () => AuthBloc(
        authRepository: authRepository,
        sessionManager: sessionManager,
      ),
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(message: 'Signing out...'),
        const Unauthenticated(),
      ],
    );
  });
}
