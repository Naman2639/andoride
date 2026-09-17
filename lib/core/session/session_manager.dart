import 'dart:async';
import '../../features/auth/domain/entities/user_role.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

/// Manages role-tailored session lifecycles and inactivity policies
class SessionManager {
  final SecureStorageService _storageService;
  final void Function()? onSessionTimedOut;

  Timer? _heartbeatTimer;
  UserRole? _activeRole;

  SessionManager({
    required SecureStorageService storageService,
    this.onSessionTimedOut,
  }) : _storageService = storageService;

  Duration getTimeoutForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppConstants.adminSessionTimeout; // 15 mins for financial & governance security
      case UserRole.teacher:
        return AppConstants.teacherSessionTimeout; // 8 hours for school day operations
      case UserRole.parent:
        return AppConstants.parentSessionTimeout; // 30 days persistent mobile session
      case UserRole.student:
        return AppConstants.studentSessionTimeout; // 30 days persistent student session
    }
  }

  /// Start or resume tracking user inactivity
  Future<void> startSession(UserRole role) async {
    _activeRole = role;
    await _storageService.recordActiveTimestamp();
    _startHeartbeat();
  }

  /// Manually record user touch or action
  Future<void> recordUserActivity() async {
    await _storageService.recordActiveTimestamp();
  }

  /// Evaluate if current session is within acceptable bounds
  Future<bool> isSessionValid(UserRole role) async {
    final lastActive = await _storageService.getLastActiveTimestamp();
    if (lastActive == null) return false;

    final allowedDuration = getTimeoutForRole(role);
    final elapsed = DateTime.now().difference(lastActive);

    return elapsed < allowedDuration;
  }

  /// Get remaining session duration (especially useful for Admin portal UI countdown pill)
  Future<Duration> getRemainingDuration(UserRole role) async {
    final lastActive = await _storageService.getLastActiveTimestamp();
    if (lastActive == null) return Duration.zero;

    final allowedDuration = getTimeoutForRole(role);
    final elapsed = DateTime.now().difference(lastActive);
    final remaining = allowedDuration - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    // Heartbeat every 30 seconds to check inactivity
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_activeRole == null) return;
      final valid = await isSessionValid(_activeRole!);
      if (!valid) {
        stopSession();
        onSessionTimedOut?.call();
      }
    });
  }

  void stopSession() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _activeRole = null;
  }
}
