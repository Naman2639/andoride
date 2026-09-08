import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, late, excused }

class AttendanceRecord extends Equatable {
  final String studentId;
  final String studentName;
  final int rollNumber;
  final AttendanceStatus status;
  final String? remarks;
  final DateTime date;
  final String session; // Morning / Afternoon

  const AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.status,
    this.remarks,
    required this.date,
    this.session = 'Morning',
  });

  @override
  List<Object?> get props => [
        studentId,
        studentName,
        rollNumber,
        status,
        remarks,
        date,
        session,
      ];
}
