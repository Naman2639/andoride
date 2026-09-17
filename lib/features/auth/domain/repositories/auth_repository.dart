import '../entities/user.dart';
import '../entities/user_role.dart';

/// Contract defining all authentication and session verification procedures
abstract class AuthRepository {
  /// Authenticate using mobile number / email and password
  Future<User> loginWithPassword({
    required String identifier,
    required String password,
  });

  /// Request OTP for mobile number / email
  Future<void> requestOtp({
    required String identifier,
  });

  /// Authenticate using OTP verification
  Future<User> verifyOtp({
    required String identifier,
    required String otp,
  });

  /// Authenticate using Google Account
  Future<User> loginWithGoogle({
    required String email,
    String? displayName,
    String? designation,
  });

  /// Re-validate existing local session upon app launch
  Future<User?> checkAuthStatus();

  /// Check if the session is currently valid without full network refresh
  Future<bool> isSessionValid(UserRole role);

  /// Revoke credentials and wipe secure storage
  Future<void> logout();
}
