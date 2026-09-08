import '../entities/exam_term.dart';

abstract class ExamsRepository {
  /// Teacher enters marks for a subject
  Future<void> submitSubjectMarks({
    required String examTermId,
    required String classId,
    required String subjectName,
    required Map<String, SubjectScore> studentMarks, // studentId -> marks
  });

  /// Admin locks marks and publishes results gate
  Future<void> publishExamResults({
    required String examTermId,
    required String classId,
  });

  /// Parent fetches digital score sheet and report card archive
  Future<List<SubjectScore>> getStudentScoreSheet({
    required String studentId,
    required String examTermId,
  });

  /// Download official school-stamped and signed PDF report card
  Future<List<int>> generateReportCardPdf({
    required String studentId,
    required String examTermId,
  });
}
