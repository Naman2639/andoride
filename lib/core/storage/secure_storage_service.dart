import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../constants/app_constants.dart';

/// Secure local storage service safeguarding tokens and identity state
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  // --- Auth Token Management ---
  Future<void> persistTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: AppConstants.keyAuthToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.keyAuthToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.keyRefreshToken);
  }

  // --- User Profile & Role Storage ---
  Future<void> persistUser(UserModel user) async {
    await _storage.write(key: AppConstants.keyUserData, value: jsonEncode(user.toJson()));
    await _storage.write(key: AppConstants.keyUserRole, value: user.role.toFormattedString());
  }

  Future<UserModel?> getUser() async {
    final rawJson = await _storage.read(key: AppConstants.keyUserData);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<UserRole?> getUserRole() async {
    final roleString = await _storage.read(key: AppConstants.keyUserRole);
    if (roleString == null || roleString.isEmpty) return null;
    try {
      return UserRole.fromString(roleString);
    } catch (_) {
      return null;
    }
  }

  // --- Session Inactivity Tracking ---
  Future<void> recordActiveTimestamp() async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: AppConstants.keyLastActiveTimestamp, value: now);
  }

  Future<DateTime?> getLastActiveTimestamp() async {
    final timestampStr = await _storage.read(key: AppConstants.keyLastActiveTimestamp);
    if (timestampStr == null) return null;
    final millis = int.tryParse(timestampStr);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  // --- Custom Persistent Data (Teachers, Students, Registry) ---
  Future<void> saveCustomData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getCustomData(String key) async {
    return await _storage.read(key: key);
  }

  // --- Clear / Logout ---
  Future<void> clearAll() async {
    await _storage.delete(key: AppConstants.keyAuthToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyUserData);
    await _storage.delete(key: AppConstants.keyUserRole);
    await _storage.delete(key: AppConstants.keyLastActiveTimestamp);
  }
}
