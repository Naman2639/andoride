/// Application-wide constants and configuration values.
class AppConstants {
  AppConstants._();

  static const String appName = 'EduGovernance ERP';

  // Secure Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyUserRole = 'user_role';
  static const String keyLastActiveTimestamp = 'last_active_timestamp';
  static const String keyCustomTeachers = 'custom_registered_teachers';
  static const String keyCustomStudents = 'custom_registered_students';

  // Session Inactivity Thresholds
  // Administrative sessions must time out quickly to safeguard governance and financial records.
  static const Duration adminSessionTimeout = Duration(minutes: 15);
  // Teacher sessions allow standard workday shift duration with periodic revalidation.
  static const Duration teacherSessionTimeout = Duration(hours: 8);
  // Parent & Student sessions are persistent for seamless daily mobile access.
  static const Duration parentSessionTimeout = Duration(days: 30);
  static const Duration studentSessionTimeout = Duration(days: 30);

  // Network Timeout Limits
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
