import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  /// Fetch daily register for a class (defaults to all present)
  Future<List<AttendanceRecord>> getClassRegister({
    required String classId,
    required DateTime date,
  });

  /// Submit roll call attendance (triggers automated notifications for absents)
  Future<void> submitClassAttendance({
    required String classId,
    required DateTime date,
    required List<AttendanceRecord> records,
  });

  /// Submit correction within grace period window
  Future<void> updateAttendanceCorrection({
    required String classId,
    required DateTime date,
    required String studentId,
    required AttendanceStatus newStatus,
    required String reason,
  });

  /// Monthly calendar view for Parent app
  Future<Map<DateTime, AttendanceStatus>> getStudentMonthlyCalendar({
    required String studentId,
    required int month,
    required int year,
  });
}
