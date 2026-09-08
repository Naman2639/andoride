import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheTokens({required String accessToken, String? refreshToken});
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<UserRole?> getCachedRole();
  Future<String?> getCachedToken();
  Future<DateTime?> getLastActive();
  Future<void> updateLastActive();
  Future<void> clearAuthCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService _storageService;

  AuthLocalDataSourceImpl({required SecureStorageService storageService})
      : _storageService = storageService;

  @override
  Future<void> cacheTokens({required String accessToken, String? refreshToken}) async {
    await _storageService.persistTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await _storageService.persistUser(user);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    return await _storageService.getUser();
  }

  @override
  Future<UserRole?> getCachedRole() async {
    return await _storageService.getUserRole();
  }

  @override
  Future<String?> getCachedToken() async {
    return await _storageService.getAccessToken();
  }

  @override
  Future<DateTime?> getLastActive() async {
    return await _storageService.getLastActiveTimestamp();
  }

  @override
  Future<void> updateLastActive() async {
    await _storageService.recordActiveTimestamp();
  }

  @override
  Future<void> clearAuthCache() async {
    await _storageService.clearAll();
  }
}
