import '../../../../core/errors/exceptions.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/user_registry_service.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final SessionManager _sessionManager;
  final UserRegistryService _userRegistryService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required SessionManager sessionManager,
    required UserRegistryService userRegistryService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _sessionManager = sessionManager,
        _userRegistryService = userRegistryService;

  UserRegistryService get userRegistry => _userRegistryService;

  @override
  Future<User> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    final result = await _remoteDataSource.loginWithPassword(
      identifier: identifier,
      password: password,
    );

    await _persistSession(result.user, result.accessToken, result.refreshToken);
    return result.user;
  }

  @override
  Future<void> requestOtp({required String identifier}) async {
    await _remoteDataSource.requestOtp(identifier: identifier);
  }

  @override
  Future<User> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    final result = await _remoteDataSource.verifyOtp(
      identifier: identifier,
      otp: otp,
    );

    await _persistSession(result.user, result.accessToken, result.refreshToken);
    return result.user;
  }

  @override
  Future<User> loginWithGoogle({
    required String email,
    String? displayName,
  }) async {
    final user = await _userRegistryService.findByGoogleEmail(email);
    if (user == null) {
      throw Exception(
        'Google account "$email" is not registered in EduGovernance records.\n\n'
        '• Teachers must be added by the School Admin.\n'
        '• Students must be enrolled by their Class Teacher.\n\n'
        'Please contact your school administrator or teacher.',
      );
    }

    final token = 'mock_google_jwt_${DateTime.now().millisecondsSinceEpoch}';
    await _persistSession(user, token, null);
    return user;
  }

  @override
  Future<User?> checkAuthStatus() async {
    final token = await _localDataSource.getCachedToken();
    if (token == null || token.isEmpty) return null;

    final user = await _localDataSource.getCachedUser();
    if (user == null) return null;

    // Enforce role-based session limits
    // Admin: short 15m timeout, Teacher: 8h shift, Parent: 30d persistent
    final isValid = await _sessionManager.isSessionValid(user.role);
    if (!isValid) {
      await logout();
      return null;
    }

    // Update active timestamp and resume session heartbeat
    await _localDataSource.updateLastActive();
    await _sessionManager.startSession(user.role);

    return user;
  }

  @override
  Future<bool> isSessionValid(UserRole role) async {
    return await _sessionManager.isSessionValid(role);
  }

  @override
  Future<void> logout() async {
    _sessionManager.stopSession();
    await _localDataSource.clearAuthCache();
    await _remoteDataSource.logout();
  }

  Future<void> _persistSession(UserModel user, String accessToken, String? refreshToken) async {
    await _localDataSource.cacheTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _localDataSource.cacheUser(user);
    await _sessionManager.startSession(user.role);
  }
}
