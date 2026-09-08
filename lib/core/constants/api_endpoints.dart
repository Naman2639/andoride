/// REST API Endpoints for School Management ERP
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.edugovernance.internal/v1';

  // Auth & RBAC
  static const String loginWithPassword = '/auth/login';
  static const String requestOtp = '/auth/otp/request';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/token/refresh';
  static const String logout = '/auth/logout';

  // Admin Master Data & Finance
  static const String adminMasterData = '/admin/academic-years';
  static const String adminStaffDirectory = '/admin/staff';
  static const String adminAuditLogs = '/admin/audit-logs';
  static const String adminFeeStructures = '/admin/fees/structures';
  static const String adminDefaulters = '/admin/fees/defaulters';
  static const String adminExams = '/admin/exams';
  static const String adminPublishResults = '/admin/exams/publish';

  // Teacher Classroom Operations
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherAttendanceCorrection = '/teacher/attendance/corrections';
  static const String teacherAssignments = '/teacher/homework';
  static const String teacherSubmissions = '/teacher/homework/submissions';
  static const String teacherMarks = '/teacher/grading/marks';

  // Parent Services
  static const String parentAttendanceCalendar = '/parent/attendance/calendar';
  static const String parentLeaveRequests = '/parent/leave-requests';
  static const String parentFeeLedger = '/parent/fees/statement';
  static const String parentPaymentInitiate = '/parent/fees/pay';
  static const String parentHomeworkFeed = '/parent/homework/feed';
  static const String parentReportCards = '/parent/exams/report-cards';
}
