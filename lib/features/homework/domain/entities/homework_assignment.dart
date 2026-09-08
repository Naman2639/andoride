import 'package:equatable/equatable.dart';

class HomeworkAssignment extends Equatable {
  final String id;
  final String subject;
  final String title;
  final String instructions;
  final DateTime dueDate;
  final String teacherName;
  final List<String> attachmentUrls;
  final bool isSubmitted;

  const HomeworkAssignment({
    required this.id,
    required this.subject,
    required this.title,
    required this.instructions,
    required this.dueDate,
    required this.teacherName,
    this.attachmentUrls = const [],
    this.isSubmitted = false,
  });

  @override
  List<Object?> get props => [
        id,
        subject,
        title,
        instructions,
        dueDate,
        teacherName,
        attachmentUrls,
        isSubmitted,
      ];
}
