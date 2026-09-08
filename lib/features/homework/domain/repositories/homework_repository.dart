import '../entities/homework_assignment.dart';

abstract class HomeworkRepository {
  /// Teacher creates and broadcasts assignment with attachments
  Future<void> publishAssignment({
    required String classId,
    required String subject,
    required String title,
    required String instructions,
    required DateTime dueDate,
    required List<String> filePaths,
  });

  /// Parent homework feed (categorized into Due Today, Upcoming, Overdue)
  Future<List<HomeworkAssignment>> getStudentHomeworkFeed(String studentId);

  /// Check submission status for teacher review
  Future<List<Map<String, dynamic>>> getAssignmentSubmissions(String assignmentId);
}
