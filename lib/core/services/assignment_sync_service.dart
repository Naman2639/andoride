import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';

/// Central synchronized service managing assignments published by teachers
/// and accessible in real-time by Students, Parents, and Admins.
class AssignmentSyncService {
  static AssignmentSyncService? _instance;

  factory AssignmentSyncService({SecureStorageService? storageService}) {
    if (_instance == null) {
      _instance = AssignmentSyncService._internal(storageService);
    } else if (storageService != null) {
      _instance!._storageService = storageService;
    }
    return _instance!;
  }

  AssignmentSyncService._internal(SecureStorageService? storageService) {
    _storageService = storageService;
    _loadFromStorage();
  }

  SecureStorageService? _storageService;
  static const String _storageKey = 'sync_assignments_store_v1';

  final ValueNotifier<List<Map<String, dynamic>>> assignmentsNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  List<Map<String, dynamic>> get currentAssignments => assignmentsNotifier.value;

  final List<Map<String, dynamic>> _defaultAssignments = [
    {
      'id': 'ASGN_101',
      'title': 'Quadratic Equations & Polynomials Problem Set 4',
      'subject': 'Mathematics',
      'class': 'Class 10-A',
      'dueDate': '24 Sep 2026',
      'maxMarks': 50,
      'instructions':
          'Solve exercises 4.1 to 4.3 from Chapter 4. Submit detailed step-by-step derivations with graph plots.',
      'attachments': [
        {'name': 'Quadratic_Equations_Ex4.pdf', 'size': '2.4 MB'},
        {'name': 'NCERT_Chapter4_Solutions.pdf', 'size': '1.8 MB'},
        {'name': 'Graph_Plotting_Reference.pdf', 'size': '980 KB'},
      ],
      'submissionsCount': 22,
      'totalCount': 25,
      'publishedDate': '18 Sep 2026',
      'isSubmitted': true,
    },
    {
      'id': 'ASGN_102',
      'title': 'Arithmetic Progressions & Real-World Modeling',
      'subject': 'Mathematics',
      'class': 'Class 10-A',
      'dueDate': '26 Sep 2026',
      'maxMarks': 30,
      'instructions':
          'Formulate real-life progression word problems and compute the 20th term & sum of sequences.',
      'attachments': [
        {'name': 'AP_Practice_Problems.pdf', 'size': '1.2 MB'},
        {'name': 'Formula_Sheet_Standard.pdf', 'size': '540 KB'},
      ],
      'submissionsCount': 19,
      'totalCount': 25,
      'publishedDate': '17 Sep 2026',
      'isSubmitted': false,
    },
    {
      'id': 'ASGN_103',
      'title': 'Optics & Wave Motion Lab Experiments',
      'subject': 'Physics',
      'class': 'Class 10-A',
      'dueDate': '28 Sep 2026',
      'maxMarks': 40,
      'instructions':
          'Record observations for refraction through glass prism and verify Snell\'s Law with ray diagrams.',
      'attachments': [
        {'name': 'Physics_Optics_Lab_Guide.pdf', 'size': '3.1 MB'},
      ],
      'submissionsCount': 15,
      'totalCount': 25,
      'publishedDate': '16 Sep 2026',
      'isSubmitted': false,
    },
  ];

  Future<void> _loadFromStorage() async {
    if (_storageService != null) {
      try {
        final raw = await _storageService!.getCustomData(_storageKey);
        if (raw != null && raw.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(raw);
          final list = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          assignmentsNotifier.value = list;
          return;
        }
      } catch (_) {}
    }

    // Default seed assignments
    assignmentsNotifier.value = List.from(_defaultAssignments);
  }

  Future<void> _persist() async {
    if (_storageService != null) {
      try {
        final raw = jsonEncode(assignmentsNotifier.value);
        await _storageService!.saveCustomData(_storageKey, raw);
      } catch (_) {}
    }
  }

  /// Adds a new assignment published by a teacher with UNLIMITED attached PDFs
  Future<void> publishAssignment({
    required String title,
    required String subject,
    required String targetClass,
    required String dueDate,
    required int maxMarks,
    required String instructions,
    required List<Map<String, String>> attachments,
    int totalCount = 25,
  }) async {
    final newAssignment = {
      'id': 'ASGN_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'subject': subject,
      'class': targetClass,
      'dueDate': dueDate,
      'maxMarks': maxMarks,
      'instructions': instructions,
      'attachments': attachments,
      'submissionsCount': 0,
      'totalCount': totalCount,
      'publishedDate': 'Today',
      'isSubmitted': false,
    };

    final updated = [newAssignment, ...assignmentsNotifier.value];
    assignmentsNotifier.value = updated;
    await _persist();
  }

  /// Marks an assignment as turned in by student
  Future<void> submitAssignment(String assignmentId) async {
    final updated = assignmentsNotifier.value.map((a) {
      if (a['id'] == assignmentId) {
        final copy = Map<String, dynamic>.from(a);
        copy['isSubmitted'] = true;
        copy['submissionsCount'] = ((copy['submissionsCount'] as int? ?? 0) + 1);
        return copy;
      }
      return a;
    }).toList();
    assignmentsNotifier.value = updated;
    await _persist();
  }

  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }
}
