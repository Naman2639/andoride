import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../auth/data/datasources/user_registry_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  late final UserRegistryService _registryService;
  List<UserModel> _students = [];
  bool _isLoadingStudents = true;
  String _selectedClass = 'Class 10-A';

  // 1. One-Tap Attendance State
  final Map<String, String> _attendanceMap = {};
  bool _attendanceSubmittedToday = false;
  String _lastAttendanceTimestamp = '';

  // 2. Attendance Correction Audit Log
  final List<Map<String, String>> _attendanceCorrections = [
    {
      'date': '17 Sep 2026',
      'student': 'Aarav Sharma (STU-10A-01)',
      'oldStatus': 'ABSENT',
      'newStatus': 'PRESENT',
      'reason': 'Medical certificate submitted on arrival; fever excused.',
      'auditedBy': 'Sarah Jenkins (Faculty)',
    },
    {
      'date': '15 Sep 2026',
      'student': 'Rohan Iyer (STU-10A-18)',
      'oldStatus': 'ABSENT',
      'newStatus': 'EXCUSED',
      'reason': 'Attended inter-school zonal mathematics olympiad.',
      'auditedBy': 'Sarah Jenkins (Faculty)',
    },
  ];

  // 3. Published Assignments State
  final List<Map<String, dynamic>> _assignments = [
    {
      'id': 'ASGN_101',
      'title': 'Quadratic Equations & Polynomials Problem Set 4',
      'subject': 'Mathematics',
      'class': 'Class 10-A',
      'dueDate': '20 Sep 2026',
      'maxMarks': 50,
      'instructions': 'Solve exercises 4.1 to 4.3 from Chapter 4. Submit detailed step-by-step derivations.',
      'attachment': 'Quadratic_Equations_Ex4.pdf',
      'submissionsCount': 22,
      'totalCount': 25,
    },
    {
      'id': 'ASGN_102',
      'title': 'Arithmetic Progressions & Real-World Modeling',
      'subject': 'Mathematics',
      'class': 'Class 10-A',
      'dueDate': '25 Sep 2026',
      'maxMarks': 30,
      'instructions': 'Formulate real-life progression word problems and compute the 20th term & sum.',
      'attachment': 'AP_Practice_Problems.pdf',
      'submissionsCount': 19,
      'totalCount': 25,
    },
  ];

  // 4. Submissions & Grading State
  final List<Map<String, dynamic>> _submissions = [
    {
      'id': 'SUB_01',
      'studentName': 'Aarav Sharma',
      'roll': 'STU-10A-01',
      'assignmentId': 'ASGN_101',
      'submissionDate': '18 Sep 2026, 08:30 AM',
      'attachmentName': 'Aarav_Sharma_Math_Sol.pdf',
      'fileSize': '1.4 MB',
      'status': 'GRADED',
      'marks': '48',
      'maxMarks': '50',
      'grade': 'A+',
      'feedback': 'Outstanding proof steps and clear quadratic formula derivation. Well structured.',
    },
    {
      'id': 'SUB_02',
      'studentName': 'Diya Patel',
      'roll': 'STU-10A-02',
      'assignmentId': 'ASGN_101',
      'submissionDate': '18 Sep 2026, 08:45 AM',
      'attachmentName': 'Diya_Math_HW.pdf',
      'fileSize': '2.1 MB',
      'status': 'GRADED',
      'marks': '46',
      'maxMarks': '50',
      'grade': 'A',
      'feedback': 'Great presentation. Double-check discriminant signs on problem 4b.',
    },
    {
      'id': 'SUB_03',
      'studentName': 'Rohan Iyer',
      'roll': 'STU-10A-03',
      'assignmentId': 'ASGN_101',
      'submissionDate': '18 Sep 2026, 09:12 AM',
      'attachmentName': 'Rohan_Calculations.pdf',
      'fileSize': '950 KB',
      'status': 'PENDING_EVALUATION',
      'marks': '',
      'maxMarks': '50',
      'grade': '',
      'feedback': '',
    },
    {
      'id': 'SUB_04',
      'studentName': 'Priya Verma',
      'roll': 'STU-10A-04',
      'assignmentId': 'ASGN_101',
      'submissionDate': 'Pending',
      'attachmentName': '',
      'fileSize': '',
      'status': 'NOT_SUBMITTED',
      'marks': '',
      'maxMarks': '50',
      'grade': '',
      'feedback': '',
    },
  ];

  // 5. Term Marks & Observations State
  final List<Map<String, dynamic>> _termMarks = [
    {
      'studentName': 'Aarav Sharma',
      'roll': 'STU-10A-01',
      'theoryMarks': 76,
      'practicalMarks': 19,
      'total': 95,
      'grade': 'A1',
      'observations': 'Exceptional problem-solving speed; demonstrated peer leadership in math lab.',
    },
    {
      'studentName': 'Diya Patel',
      'roll': 'STU-10A-02',
      'theoryMarks': 72,
      'practicalMarks': 18,
      'total': 90,
      'grade': 'A1',
      'observations': 'Consistent high achiever with excellent conceptual clarity and neat work.',
    },
    {
      'studentName': 'Rohan Iyer',
      'roll': 'STU-10A-03',
      'theoryMarks': 65,
      'practicalMarks': 17,
      'total': 82,
      'grade': 'A2',
      'observations': 'Solid understanding of core theorems; needs more practice in algebraic proofs.',
    },
    {
      'studentName': 'Priya Verma',
      'roll': 'STU-10A-04',
      'theoryMarks': 68,
      'practicalMarks': 18,
      'total': 86,
      'grade': 'A2',
      'observations': 'Active participant during class discussions; excellent analytical skills.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _registryService = UserRegistryService(storageService: SecureStorageService());
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final list = await _registryService.getAllStudents(classFilter: _selectedClass);
    if (mounted) {
      setState(() {
        _students = list;
        _isLoadingStudents = false;
        // Initialize attendance map to Present for all
        for (final s in list) {
          _attendanceMap.putIfAbsent(s.id, () => 'P');
        }
      });
    }
  }

  // ===========================================================================
  // FEATURE 1: ONE-TAP ATTENDANCE
  // ===========================================================================
  void _showOneTapAttendanceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final total = _students.length;
            final present = _attendanceMap.values.where((v) => v == 'P').length;
            final absent = _attendanceMap.values.where((v) => v == 'A').length;
            final lateCount = _attendanceMap.values.where((v) => v == 'L').length;
            final rate = total > 0 ? (((present + (lateCount * 0.5)) / total) * 100).toStringAsFixed(1) : '100.0';

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 26),
                          SizedBox(width: 10),
                          Text(
                            'One-Tap Attendance Register',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_selectedClass • Daily Roll Call • Today: 18 Sep 2026',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),

                  // Summary metrics pill bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAttendanceMetric('Total', '$total', const Color(0xFF475569)),
                        _buildAttendanceMetric('Present', '$present', const Color(0xFF16A34A)),
                        _buildAttendanceMetric('Absent', '$absent', const Color(0xFFDC2626)),
                        _buildAttendanceMetric('Late', '$lateCount', const Color(0xFFD97706)),
                        _buildAttendanceMetric('Rate', '$rate%', const Color(0xFF059669)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setSheetState(() {
                              for (final s in _students) {
                                _attendanceMap[s.id] = 'P';
                              }
                            });
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All enrolled students marked PRESENT with 1-Tap!'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Color(0xFF16A34A),
                              ),
                            );
                          },
                          icon: const Icon(Icons.done_all, size: 18),
                          label: const Text('1-Tap Mark All Present'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF065F46),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          setSheetState(() {
                            for (final s in _students) {
                              _attendanceMap[s.id] = 'P';
                            }
                          });
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),

                  // Student Roster with Toggle Chips
                  Expanded(
                    child: ListView.separated(
                      itemCount: _students.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (ctx, index) {
                        final s = _students[index];
                        final status = _attendanceMap[s.id] ?? 'P';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF0284C7).withOpacity(0.12),
                                child: Text(
                                  s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                                  style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                    Text('ID: ${s.id} • ${s.designation ?? _selectedClass}',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _buildAttendanceStatusPill('P', 'Present', status == 'P', const Color(0xFF16A34A), () {
                                    setSheetState(() => _attendanceMap[s.id] = 'P');
                                    setState(() {});
                                  }),
                                  const SizedBox(width: 4),
                                  _buildAttendanceStatusPill('A', 'Absent', status == 'A', const Color(0xFFDC2626), () {
                                    setSheetState(() => _attendanceMap[s.id] = 'A');
                                    setState(() {});
                                  }),
                                  const SizedBox(width: 4),
                                  _buildAttendanceStatusPill('L', 'Late', status == 'L', const Color(0xFFD97706), () {
                                    setSheetState(() => _attendanceMap[s.id] = 'L');
                                    setState(() {});
                                  }),
                                  const SizedBox(width: 4),
                                  _buildAttendanceStatusPill('E', 'Excused', status == 'E', const Color(0xFF2563EB), () {
                                    setSheetState(() => _attendanceMap[s.id] = 'E');
                                    setState(() {});
                                  }),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _attendanceSubmittedToday = true;
                        _lastAttendanceTimestamp = '18 Sep 2026, 09:15 AM';
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Attendance for $_selectedClass ($present Present, $absent Absent) submitted & synced!'),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF065F46),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Submit & Save Daily Attendance', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildAttendanceStatusPill(String code, String label, bool isSelected, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : color.withOpacity(0.3)),
        ),
        child: Text(
          code,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // FEATURE 2: ATTENDANCE CORRECTION
  // ===========================================================================
  void _showAttendanceCorrectionDialog() {
    String selectedDate = '17 Sep 2026 (Yesterday)';
    String selectedStudent = _students.isNotEmpty ? _students.first.name : 'Aarav Sharma';
    String prevStatus = 'ABSENT';
    String newStatus = 'PRESENT';
    final reasonController = TextEditingController(text: 'Medical certificate verified by nurse.');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.edit_calendar, color: Color(0xFF7C3AED)),
                  SizedBox(width: 10),
                  Text('Attendance Correction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Submit an audited correction for accidental mis-marks or medical leave approvals.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDate,
                      decoration: const InputDecoration(labelText: 'Select Date', prefixIcon: Icon(Icons.calendar_today, size: 18)),
                      items: const [
                        DropdownMenuItem(value: '17 Sep 2026 (Yesterday)', child: Text('17 Sep 2026 (Yesterday)')),
                        DropdownMenuItem(value: '16 Sep 2026', child: Text('16 Sep 2026')),
                        DropdownMenuItem(value: '15 Sep 2026', child: Text('15 Sep 2026')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedDate = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStudent,
                      decoration: const InputDecoration(labelText: 'Student Roster', prefixIcon: Icon(Icons.person, size: 18)),
                      items: _students.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedStudent = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: prevStatus,
                            decoration: const InputDecoration(labelText: 'Previous Status'),
                            items: const [
                              DropdownMenuItem(value: 'ABSENT', child: Text('ABSENT', style: TextStyle(color: Color(0xFFDC2626)))),
                              DropdownMenuItem(value: 'LATE', child: Text('LATE', style: TextStyle(color: Color(0xFFD97706)))),
                              DropdownMenuItem(value: 'PRESENT', child: Text('PRESENT', style: TextStyle(color: Color(0xFF16A34A)))),
                            ],
                            onChanged: (v) {
                              if (v != null) setDialogState(() => prevStatus = v);
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward, color: Color(0xFF94A3B8)),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: newStatus,
                            decoration: const InputDecoration(labelText: 'Corrected To'),
                            items: const [
                              DropdownMenuItem(value: 'PRESENT', child: Text('PRESENT', style: TextStyle(color: Color(0xFF16A34A)))),
                              DropdownMenuItem(value: 'EXCUSED', child: Text('EXCUSED', style: TextStyle(color: Color(0xFF2563EB)))),
                              DropdownMenuItem(value: 'LATE', child: Text('LATE', style: TextStyle(color: Color(0xFFD97706)))),
                            ],
                            onChanged: (v) {
                              if (v != null) setDialogState(() => newStatus = v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Justification / Audit Reason',
                        hintText: 'e.g. Parent sent doctor slip; approved.',
                        prefixIcon: Icon(Icons.notes, size: 18),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _attendanceCorrections.insert(0, {
                        'date': selectedDate.split(' ')[0],
                        'student': selectedStudent,
                        'oldStatus': prevStatus,
                        'newStatus': newStatus,
                        'reason': reasonController.text.trim(),
                        'auditedBy': 'Sarah Jenkins (Faculty)',
                      });
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Correction applied for $selectedStudent ($prevStatus -> $newStatus)!'),
                        backgroundColor: const Color(0xFF7C3AED),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply Correction'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // FEATURE 3: PUBLISH ASSIGNMENT
  // ===========================================================================
  void _showPublishAssignmentDialog() {
    final titleCtrl = TextEditingController(text: 'Coordinate Geometry & Straight Lines Exercise 5');
    final descCtrl = TextEditingController(text: 'Complete questions 1 to 10 from NCERT Textbook with graph plots.');
    final marksCtrl = TextEditingController(text: '40');
    String dueDate = '24 Sep 2026';
    String attachment = 'Coordinate_Geometry_Ex5.pdf';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.assignment_add, color: Color(0xFF2563EB)),
                  SizedBox(width: 10),
                  Text('Publish Assignment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Post structured homework to student vault with attached document.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Assignment Title', prefixIcon: Icon(Icons.title)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: marksCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Max Marks', prefixIcon: Icon(Icons.star_outline)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Due Date',
                              hintText: dueDate,
                              prefixIcon: const Icon(Icons.calendar_today, size: 18),
                            ),
                            onTap: () {
                              setDialogState(() => dueDate = '26 Sep 2026');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Problem Instructions', prefixIcon: Icon(Icons.description)),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: attachment,
                      decoration: const InputDecoration(labelText: 'Attached Document / PDF', prefixIcon: Icon(Icons.attach_file)),
                      items: const [
                        DropdownMenuItem(value: 'Coordinate_Geometry_Ex5.pdf', child: Text('Coordinate_Geometry_Ex5.pdf')),
                        DropdownMenuItem(value: 'Formula_Sheet_Standard.pdf', child: Text('Formula_Sheet_Standard.pdf')),
                        DropdownMenuItem(value: 'Practice_Questions_Advanced.pdf', child: Text('Practice_Questions_Advanced.pdf')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => attachment = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _assignments.insert(0, {
                        'id': 'ASGN_${DateTime.now().millisecondsSinceEpoch}',
                        'title': titleCtrl.text.trim(),
                        'subject': 'Mathematics',
                        'class': _selectedClass,
                        'dueDate': dueDate,
                        'maxMarks': int.tryParse(marksCtrl.text.trim()) ?? 40,
                        'instructions': descCtrl.text.trim(),
                        'attachment': attachment,
                        'submissionsCount': 0,
                        'totalCount': _students.length,
                      });
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Assignment "${titleCtrl.text.trim()}" published to $_selectedClass Vault!'),
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  child: const Text('Publish to Class'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // FEATURE 4: SUBMISSION STATUS & GRADING
  // ===========================================================================
  void _showSubmissionsAndGradingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.rate_review, color: Color(0xFF0284C7), size: 26),
                          SizedBox(width: 10),
                          Text(
                            'Submission Status & Grading',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Active Assignment: Quadratic Equations Problem Set 4 (Max Marks: 50)',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _submissions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (ctx, index) {
                        final sub = _submissions[index];
                        final isGraded = sub['status'] == 'GRADED';
                        final isPending = sub['status'] == 'PENDING_EVALUATION';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 6),
                          leading: CircleAvatar(
                            backgroundColor: isGraded
                                ? const Color(0xFF16A34A).withOpacity(0.12)
                                : isPending
                                    ? const Color(0xFFD97706).withOpacity(0.12)
                                    : const Color(0xFF94A3B8).withOpacity(0.12),
                            child: Icon(
                              isGraded
                                  ? Icons.check
                                  : isPending
                                      ? Icons.hourglass_top
                                      : Icons.remove,
                              color: isGraded
                                  ? const Color(0xFF16A34A)
                                  : isPending
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                          title: Text(sub['studentName'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub['status'] == 'NOT_SUBMITTED'
                                    ? 'Status: Pending Student Upload'
                                    : 'File: ${sub['attachmentName']} (${sub['fileSize']}) • ${sub['submissionDate']}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              if (isGraded)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Feedback: "${sub['feedback']}"',
                                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF047857)),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isGraded)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                                  child: Text('${sub['marks']}/${sub['maxMarks']} (${sub['grade']})',
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF065F46), fontSize: 12)),
                                ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: sub['status'] == 'NOT_SUBMITTED'
                                    ? null
                                    : () {
                                        _showGradeDialog(sub, () {
                                          setSheetState(() {});
                                          setState(() {});
                                        });
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isGraded ? const Color(0xFFF1F5F9) : const Color(0xFF0284C7),
                                  foregroundColor: isGraded ? const Color(0xFF0F172A) : Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                child: Text(isGraded ? 'Review' : 'Grade', style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGradeDialog(Map<String, dynamic> sub, VoidCallback onGraded) {
    final marksCtrl = TextEditingController(text: sub['marks']?.toString().isNotEmpty == true ? sub['marks'].toString() : '47');
    final feedbackCtrl = TextEditingController(text: sub['feedback']?.toString().isNotEmpty == true ? sub['feedback'].toString() : 'Good work on derivations.');
    String grade = sub['grade']?.toString().isNotEmpty == true ? sub['grade'].toString() : 'A+';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Grade: ${sub['studentName']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${sub['attachmentName']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening ${sub['attachmentName']} in Secure Viewer...')),
                      );
                    },
                    child: const Text('Preview'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: marksCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Score / 50'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: grade,
                      decoration: const InputDecoration(labelText: 'Grade'),
                      items: const [
                        DropdownMenuItem(value: 'A+', child: Text('A+ (90-100%)')),
                        DropdownMenuItem(value: 'A', child: Text('A (80-89%)')),
                        DropdownMenuItem(value: 'B+', child: Text('B+ (70-79%)')),
                        DropdownMenuItem(value: 'B', child: Text('B (60-69%)')),
                      ],
                      onChanged: (v) {
                        if (v != null) grade = v;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feedbackCtrl,
                decoration: const InputDecoration(labelText: 'Teacher Observations & Feedback'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                sub['marks'] = marksCtrl.text.trim();
                sub['grade'] = grade;
                sub['feedback'] = feedbackCtrl.text.trim();
                sub['status'] = 'GRADED';
                Navigator.pop(ctx);
                onGraded();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Grade saved for ${sub['studentName']}!'), backgroundColor: const Color(0xFF16A34A)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF065F46), foregroundColor: Colors.white),
              child: const Text('Save & Publish Grade'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // FEATURE 5: ENTER TERM MARKS & OBSERVATIONS
  // ===========================================================================
  void _showEnterTermMarksSheet() {
    String selectedTerm = 'Term 1 Final Examination';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.grading, color: Color(0xFFD97706), size: 26),
                          SizedBox(width: 10),
                          Text(
                            'Enter Term Marks & Observations',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Input theory marks (out of 80), practical assessment (out of 20), and qualitative remarks.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: selectedTerm,
                    decoration: const InputDecoration(labelText: 'Examination Session', prefixIcon: Icon(Icons.event_note)),
                    items: const [
                      DropdownMenuItem(value: 'Term 1 Final Examination', child: Text('Term 1 Final Examination')),
                      DropdownMenuItem(value: 'Mid-Term Diagnostic Assessment', child: Text('Mid-Term Diagnostic Assessment')),
                      DropdownMenuItem(value: 'Unit Test 2 Series', child: Text('Unit Test 2 Series')),
                    ],
                    onChanged: (v) {
                      if (v != null) setSheetState(() => selectedTerm = v);
                    },
                  ),
                  const SizedBox(height: 14),
                  const Divider(),

                  Expanded(
                    child: ListView.separated(
                      itemCount: _termMarks.length,
                      separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9)),
                      itemBuilder: (ctx, idx) {
                        final tm = _termMarks[idx];
                        final theoryCtrl = TextEditingController(text: tm['theoryMarks'].toString());
                        final practCtrl = TextEditingController(text: tm['practicalMarks'].toString());
                        final obsCtrl = TextEditingController(text: tm['observations'].toString());

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(tm['studentName'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                    child: Text(tm['roll'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      'Total: ${tm['total']}/100 • Grade: ${tm['grade']}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: theoryCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Theory (/80)', contentPadding: EdgeInsets.all(10)),
                                      onChanged: (v) {
                                        final th = int.tryParse(v) ?? 0;
                                        final pr = tm['practicalMarks'] as int;
                                        tm['theoryMarks'] = th;
                                        tm['total'] = th + pr;
                                        setSheetState(() {});
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: practCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Practical (/20)', contentPadding: EdgeInsets.all(10)),
                                      onChanged: (v) {
                                        final pr = int.tryParse(v) ?? 0;
                                        final th = tm['theoryMarks'] as int;
                                        tm['practicalMarks'] = pr;
                                        tm['total'] = th + pr;
                                        setSheetState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: obsCtrl,
                                decoration: const InputDecoration(labelText: 'Behavioral & Academic Observations', contentPadding: EdgeInsets.all(10)),
                                onChanged: (v) => tm['observations'] = v,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Marks for $selectedTerm finalized and published to Examination Archive!'),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    },
                    icon: const Icon(Icons.verified),
                    label: const Text('Sign & Publish Term Marks to Exam Archive'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF065F46),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // FEATURE 6: ENROLL NEW STUDENT ID
  // ===========================================================================
  void _showEnrollStudentDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final rollCtrl = TextEditingController(text: 'STU-10A-${_students.length + 15}');
    final guardianCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.school, color: Color(0xFF059669)),
              SizedBox(width: 10),
              Text('Enroll New Student ID', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Assign a new Student ID and Google authorization. The student will be able to sign in using this Google Account.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Student Full Name',
                      hintText: 'e.g. Priya Sharma',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Student name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Student Google Email',
                      hintText: 'e.g. priya.student@gmail.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Google email required';
                      if (!v.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: rollCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Roll Number / Student ID',
                      hintText: 'e.g. STU-10A-25',
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: guardianCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Guardian Name & Phone',
                      hintText: 'e.g. Rajesh Sharma (+91 9876543210)',
                      prefixIcon: Icon(Icons.family_restroom),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    await _registryService.registerNewStudent(
                      name: nameCtrl.text.trim(),
                      googleEmail: emailCtrl.text.trim(),
                      rollNumber: rollCtrl.text.trim(),
                      className: _selectedClass,
                      guardianName: guardianCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                    await _loadStudents();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Student "${nameCtrl.text.trim()}" enrolled! Can now sign in with Google: ${emailCtrl.text.trim()}'),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFDC2626)),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF065F46),
                foregroundColor: Colors.white,
              ),
              child: const Text('Enroll Student ID'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // MAIN VIEW
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final activeUser = authState is Authenticated ? authState.user : null;
    final teacherName = activeUser?.name ?? 'Sarah Jenkins, M.Sc.';
    final teacherDesignation = activeUser?.designation ?? 'Class Teacher (Grade 10-A) • Mathematics Faculty';

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Profile & Assigned Class Banner
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.co_present,
                        size: 34,
                        color: Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                teacherName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF065F46),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'FACULTY',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            teacherDesignation,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_selectedClass • Enrolled: ${_students.length} Students • ${_attendanceSubmittedToday ? "Attendance Synced ($lastTimestamp)" : "Attendance Ready"}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showEnrollStudentDialog,
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Enroll Student ID'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF065F46),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Daily Classroom Operations Hub
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Daily Classroom Operations Hub',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
                ),
                Text(
                  'Full Interactive Workflows',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Grid
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    title: 'One-Tap Attendance',
                    subtitle: _attendanceSubmittedToday ? 'Status: Marked & Synced Today' : 'Alphabetical roll call. 1-Tap "Mark All Present".',
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF059669),
                    badgeText: _attendanceSubmittedToday ? 'SYNCED' : 'READY',
                    badgeColor: _attendanceSubmittedToday ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                    onTap: _showOneTapAttendanceSheet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionTile(
                    title: 'Publish Assignment',
                    subtitle: 'Create problem sets, due dates, and document attachments.',
                    icon: Icons.assignment_add,
                    iconColor: const Color(0xFF2563EB),
                    badgeText: '${_assignments.length} ACTIVE',
                    badgeColor: const Color(0xFF2563EB),
                    onTap: _showPublishAssignmentDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    title: 'Submission Status & Grading',
                    subtitle: 'Inspect student solutions, grade out of 50, and give remarks.',
                    icon: Icons.rate_review_outlined,
                    iconColor: const Color(0xFF0284C7),
                    badgeText: 'REVIEW',
                    badgeColor: const Color(0xFF0284C7),
                    onTap: _showSubmissionsAndGradingSheet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionTile(
                    title: 'Enter Term Marks & Remarks',
                    subtitle: 'Theory (/80) & practical (/20) inputs with GPA compilation.',
                    icon: Icons.grading,
                    iconColor: const Color(0xFFD97706),
                    badgeText: 'GRADEBOOK',
                    badgeColor: const Color(0xFFD97706),
                    onTap: _showEnterTermMarksSheet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    title: 'Attendance Correction Window',
                    subtitle: 'Audited window for accidental mis-marks or medical approvals.',
                    icon: Icons.edit_calendar_outlined,
                    iconColor: const Color(0xFF7C3AED),
                    badgeText: '${_attendanceCorrections.length} AUDITED',
                    badgeColor: const Color(0xFF7C3AED),
                    onTap: _showAttendanceCorrectionDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Class Roster & Student Accounts Management
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Class Roster & Student Accounts',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Authorized Student IDs enrolled by you. Each student signs in via Google.',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_students.length} Enrolled',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    if (_isLoadingStudents)
                      const Center(child: CircularProgressIndicator())
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _students.length,
                        separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final s = _students[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF0284C7).withOpacity(0.12),
                              child: Text(
                                s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                                style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                  child: Text(s.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              'Google: ${s.emailOrPhone} • ${s.designation ?? _selectedClass}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            trailing: s.id != 'USR_STUDENT_01'
                                ? IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 20),
                                    tooltip: 'Remove Student',
                                    onPressed: () async {
                                      await _registryService.deleteStudent(s.id);
                                      await _loadStudents();
                                    },
                                  )
                                : const Chip(label: Text('Sample Student', style: TextStyle(fontSize: 10))),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get lastTimestamp => _lastAttendanceTimestamp.isNotEmpty ? _lastAttendanceTimestamp : '09:15 AM';

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 26, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            badgeText,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}
