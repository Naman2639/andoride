/// Central registry of all typed route paths
class RoutePaths {
  RoutePaths._();

  // Authentication Gateway
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';

  // Admin Portal & Sub-routes
  static const String adminDashboard = '/admin';
  static const String adminMasterData = '/admin/master-data';
  static const String adminStaffDirectory = '/admin/staff';
  static const String adminFeesEngine = '/admin/fees';
  static const String adminExams = '/admin/exams';
  static const String adminAuditLogs = '/admin/audit';

  // Teacher Portal & Sub-routes
  static const String teacherDashboard = '/teacher';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherHomework = '/teacher/homework';
  static const String teacherGrading = '/teacher/grading';

  // Parent Portal & Sub-routes
  static const String parentDashboard = '/parent';
  static const String parentCalendar = '/parent/calendar';
  static const String parentFeeLedger = '/parent/fees';
  static const String parentHomeworkFeed = '/parent/homework';
  static const String parentReports = '/parent/reports';

  // Student Portal & Sub-routes
  static const String studentDashboard = '/student';
}
