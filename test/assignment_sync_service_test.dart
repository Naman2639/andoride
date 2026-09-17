import 'package:flutter_test/flutter_test.dart';
import 'package:school_erp/core/services/assignment_sync_service.dart';
import 'package:school_erp/core/storage/secure_storage_service.dart';

class FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<void> saveCustomData(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> getCustomData(String key) async => _data[key];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssignmentSyncService Tests', () {
    late FakeSecureStorageService fakeStorage;
    late AssignmentSyncService service;

    setUp(() {
      fakeStorage = FakeSecureStorageService();
      service = AssignmentSyncService(storageService: fakeStorage);
    });

    test('should initialize with default assignments', () {
      final assignments = service.currentAssignments;
      expect(assignments, isNotEmpty);
      expect(assignments.any((a) => a['title'].toString().contains('Quadratic')), isTrue);
    });

    test('should publish new assignment with unlimited attached PDFs', () async {
      final initialCount = service.currentAssignments.length;
      final customPdfs = [
        {'name': 'Calculus_Derivatives_CheatSheet.pdf', 'size': '2.4 MB'},
        {'name': 'Integration_Practice_Ex1.pdf', 'size': '1.8 MB'},
        {'name': 'Formula_Handbook_2026.pdf', 'size': '5.2 MB'},
        {'name': 'Extra_Credit_Problem_Set.pdf', 'size': '900 KB'},
      ];

      await service.publishAssignment(
        title: 'Advanced Calculus Mastery Session',
        subject: 'Mathematics',
        targetClass: 'Class 10-A',
        dueDate: '30 Sep 2026',
        maxMarks: 50,
        instructions: 'Solve all problems in the 4 attached PDFs.',
        attachments: customPdfs,
      );

      expect(service.currentAssignments.length, equals(initialCount + 1));
      final published = service.currentAssignments.first;
      expect(published['title'], equals('Advanced Calculus Mastery Session'));
      expect((published['attachments'] as List).length, equals(4));
    });

    test('should submit assignment and update status', () async {
      final firstId = service.currentAssignments.first['id'].toString();
      await service.submitAssignment(firstId);

      final updated = service.currentAssignments.firstWhere((a) => a['id'] == firstId);
      expect(updated['isSubmitted'], isTrue);
    });
  });
}
