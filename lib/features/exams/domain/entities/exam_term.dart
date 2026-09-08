import 'package:equatable/equatable.dart';

class SubjectScore extends Equatable {
  final String subjectName;
  final double theoryMarks;
  final double practicalMarks;
  final double internalMarks;
  final double maxMarks;
  final String grade;

  const SubjectScore({
    required this.subjectName,
    required this.theoryMarks,
    required this.practicalMarks,
    required this.internalMarks,
    required this.maxMarks,
    required this.grade,
  });

  double get totalMarks => theoryMarks + practicalMarks + internalMarks;

  @override
  List<Object?> get props => [
        subjectName,
        theoryMarks,
        practicalMarks,
        internalMarks,
        maxMarks,
        grade,
      ];
}

class ExamTerm extends Equatable {
  final String id;
  final String title; // Unit Test, Mid-Term, Finals
  final String academicYear;
  final bool isLocked;
  final bool isPublished;

  const ExamTerm({
    required this.id,
    required this.title,
    required this.academicYear,
    this.isLocked = false,
    this.isPublished = false,
  });

  @override
  List<Object?> get props => [id, title, academicYear, isLocked, isPublished];
}
