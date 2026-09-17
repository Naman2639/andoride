import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../auth/data/datasources/user_registry_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_role.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final UserRegistryService _registryService;

  List<UserModel> _teachers = [];
  bool _isLoadingTeachers = true;

  // Leave applications state
  final List<Map<String, dynamic>> _leaveApplications = [
    {
      'id': 'LV-101',
      'teacherName': 'Sarah Jenkins, M.Sc.',
      'email': 'teacher.sarah@gmail.com',
      'type': 'Medical Leave',
      'dates': 'Sep 22 - Sep 24 (3 days)',
      'reason': 'Medical recovery post minor surgery',
      'status': 'Pending',
    },
    {
      'id': 'LV-102',
      'teacherName': 'Marcus Brody, Ph.D.',
      'email': 'marcus.brody@gmail.com',
      'type': 'Casual Leave',
      'dates': 'Sep 25 (1 day)',
      'reason': 'Family emergency in hometown',
      'status': 'Pending',
    },
    {
      'id': 'LV-103',
      'teacherName': 'Elena Rostova',
      'email': 'elena.rostova@gmail.com',
      'type': 'Academic Training',
      'dates': 'Oct 02 - Oct 04 (3 days)',
      'reason': 'CBSE National Pedagogical Workshop',
      'status': 'Approved',
    },
  ];

  // Classroom Live Monitoring & Homework
  final List<Map<String, dynamic>> _classroomHomework = [
    {
      'class': 'Class 10-A',
      'teacher': 'Sarah Jenkins',
      'subject': 'Mathematics',
      'runningTopic': 'Quadratic Equations & Parabolic Roots',
      'homeworkTitle': 'Exercise 4.3 Word Problems (Q1-Q8)',
      'dueDate': 'Tomorrow, 9:00 AM',
      'submissions': '38 / 42 Submitted',
      'docTitle': 'Math_Worksheet_Ch4_Quadratic.pdf',
      'docPages': 4,
      'docContent':
          'Comprehensive practice questions involving projectile motion equations, speed-time quadratic relations, and roots factorization steps.',
    },
    {
      'class': 'Class 10-B',
      'teacher': 'David Miller',
      'subject': 'Physics',
      'runningTopic': 'Ray Optics: Snell\'s Law & Refraction Index',
      'homeworkTitle': 'Laboratory Reflection Diagram Worksheet',
      'dueDate': 'Friday, 11:30 AM',
      'submissions': '35 / 40 Submitted',
      'docTitle': 'Physics_Lab_Refraction_Exp05.pdf',
      'docPages': 3,
      'docContent':
          'Draw ray tracing through a rectangular glass slab. Calculate apparent depth vs real depth using refractive index 1.5.',
    },
    {
      'class': 'Class 9-A',
      'teacher': 'Ananya Sharma',
      'subject': 'English Literature',
      'runningTopic': 'The Road Not Taken - Analytical Poetry Critique',
      'homeworkTitle': 'Theme Analysis Essay (300 Words)',
      'dueDate': 'Monday, 8:30 AM',
      'submissions': '41 / 41 Submitted',
      'docTitle': 'Frost_Poetry_Essay_Prompt.pdf',
      'docPages': 2,
      'docContent':
          'Critically analyze Robert Frost\'s use of extended metaphors and divergence symbolism in line 1-12.',
    },
  ];

  // Fee Ledger & Defaulters
  final List<Map<String, dynamic>> _feeLedger = [
    {
      'studentName': 'Liam Scott',
      'rollNo': 'STU-10A-01',
      'class': 'Class 10-A',
      'totalFee': 18500,
      'paidAmount': 18500,
      'dueAmount': 0,
      'status': 'Paid',
    },
    {
      'studentName': 'Aarav Patel',
      'rollNo': 'STU-10A-07',
      'class': 'Class 10-A',
      'totalFee': 18500,
      'paidAmount': 10000,
      'dueAmount': 8500,
      'status': 'Partial Due',
    },
    {
      'studentName': 'Devansh Singhal',
      'rollNo': 'STU-10A-19',
      'class': 'Class 10-A',
      'totalFee': 18500,
      'paidAmount': 0,
      'dueAmount': 18500,
      'status': 'Defaulter (>60 Days)',
    },
    {
      'studentName': 'Pooja Verma',
      'rollNo': 'STU-9B-12',
      'class': 'Class 9-B',
      'totalFee': 16000,
      'paidAmount': 16000,
      'dueAmount': 0,
      'status': 'Paid',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _registryService = UserRegistryService(storageService: SecureStorageService());
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final list = await _registryService.getAllTeachers();
    if (mounted) {
      setState(() {
        _teachers = list;
        _isLoadingTeachers = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Actions ---

  void _showAddTeacherDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final desigCtrl = TextEditingController(text: 'Senior Faculty Member');
    final classCtrl = TextEditingController(text: 'Class 10-A');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.person_add_alt_1, color: Color(0xFF0F172A)),
              SizedBox(width: 10),
              Text('Register New Teacher ID', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create a new teacher authorization. The teacher will be able to sign in using this Google Account.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'e.g. John Doe, M.Sc.',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Google Email Account',
                      hintText: 'e.g. john.doe.teacher@gmail.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email required';
                      if (!v.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: desigCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Designation / Subject',
                      hintText: 'e.g. Mathematics Faculty',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: classCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Classes',
                      hintText: 'e.g. Class 10-A, Class 9-B',
                      prefixIcon: Icon(Icons.class_outlined),
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
                    await _registryService.registerNewTeacher(
                      name: nameCtrl.text.trim(),
                      googleEmail: emailCtrl.text.trim(),
                      designation: desigCtrl.text.trim(),
                      assignedClasses: classCtrl.text.split(',').map((c) => c.trim()).toList(),
                    );
                    Navigator.pop(ctx);
                    await _loadTeachers();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Teacher ID created! "${emailCtrl.text.trim()}" can now sign in with Google.'),
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
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Register Teacher ID'),
            ),
          ],
        );
      },
    );
  }

  void _showUpiPaymentDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.qr_code_2, color: Color(0xFF0F172A), size: 28),
              SizedBox(width: 10),
              Text('Instant UPI Fee Collection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Student: ${item['studentName']} (${item['rollNo']})',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pending Dues: \$${item['dueAmount']}',
                  style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 16),
                // Simulated QR Code Frame
                Container(
                  width: 180,
                  height: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_scanner, size: 90, color: Color(0xFF0F172A)),
                        const SizedBox(height: 6),
                        Text(
                          'UPI ID: schoolfees@okaxis',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                        ),
                        Text(
                          'Amount: \$${item['dueAmount']}',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF16A34A), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Scan via Google Pay, PhonePe, Paytm, or BHIM to settle term balance immediately.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  item['paidAmount'] = item['totalFee'];
                  item['dueAmount'] = 0;
                  item['status'] = 'Paid';
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('UPI Payment of \$${item['totalFee']} verified and recorded in Ledger!'),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              },
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Simulate Successful Payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDocumentViewerDialog(Map<String, dynamic> hw) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626), size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hw['docTitle'] as String,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: Color(0xFF0F172A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${hw['class']} • ${hw['subject']} • ${hw['teacher']}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Curriculum Homework Document Content:', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hw['docContent'] as String,
                      style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF334155)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Pages: ${hw['docPages']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      Text('Due Date: ${hw['dueDate']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close Viewer'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloaded ${hw['docTitle']} to local device storage.')),
                );
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReportCardDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.workspace_premium, color: Color(0xFFD97706), size: 28),
              SizedBox(width: 10),
              Text('Official Examination Report Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('EduGovernance Model Senior Secondary School', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Academic Year 2026-2027 • Term 1 Summative Assessment', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Divider(height: 20),
                        Text('Student: Alex Rivera • Roll No: STU-10A-14 • Class: 10-A', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Max')),
                        DataColumn(label: Text('Scored')),
                        DataColumn(label: Text('Grade')),
                      ],
                      rows: const [
                        DataRow(cells: [DataCell(Text('Mathematics')), DataCell(Text('100')), DataCell(Text('94')), DataCell(Text('A1'))]),
                        DataRow(cells: [DataCell(Text('Physics')), DataCell(Text('100')), DataCell(Text('91')), DataCell(Text('A1'))]),
                        DataRow(cells: [DataCell(Text('Chemistry')), DataCell(Text('100')), DataCell(Text('88')), DataCell(Text('A2'))]),
                        DataRow(cells: [DataCell(Text('English Core')), DataCell(Text('100')), DataCell(Text('95')), DataCell(Text('A1'))]),
                        DataRow(cells: [DataCell(Text('Computer Sci')), DataCell(Text('100')), DataCell(Text('98')), DataCell(Text('A1'))]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, color: Color(0xFF059669), size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Digitally Signed & Certified by Dr. Robert Vance, Principal / Administrator on Sep 15, 2026.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF065F46), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Certified Report Card generated and downloaded as PDF.')),
                );
              },
              icon: const Icon(Icons.print, size: 16),
              label: const Text('Print / Export PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Responsive Header Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 650;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Institution Governance Hub',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Live Institutional Analytics, Role Allocation & Real-Time Classroom Watch',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _showAddTeacherDialog,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Register New Teacher ID'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Institution Governance Hub',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Live Analytics, Role Allocation & Classroom Watch',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _showAddTeacherDialog,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Register New Teacher ID'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),

          // Primary Module Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF0F172A),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              indicatorColor: const Color(0xFF0F172A),
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.pie_chart, size: 18), text: 'Attendance Analytics'),
                Tab(icon: Icon(Icons.badge, size: 18), text: 'Teacher Registry'),
                Tab(icon: Icon(Icons.event_available, size: 18), text: 'Leave Calendar & Approvals'),
                Tab(icon: Icon(Icons.account_balance_wallet, size: 18), text: 'Fee Ledger & UPI'),
                Tab(icon: Icon(Icons.menu_book, size: 18), text: 'Classroom Watch & Homework'),
                Tab(icon: Icon(Icons.assessment, size: 18), text: 'Exam Archive & Reports'),
              ],
            ),
          ),

          // Tab Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAttendanceAnalyticsTab(),
                _buildTeacherRegistryTab(),
                _buildLeaveCalendarTab(),
                _buildFeeLedgerTab(),
                _buildClassroomHomeworkTab(),
                _buildExamArchiveTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: ATTENDANCE ANALYTICS (PIE CHART)
  // ==========================================
  Widget _buildAttendanceAnalyticsTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;

        final pieCard = Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Teacher Attendance Rate (Today)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '88% Present',
                        style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CustomPaint(
                        painter: _PieChartPainter(
                          presentPct: 0.88,
                          leavePct: 0.08,
                          absentPct: 0.04,
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendRow('Present & In-Class', '60 Teachers (88%)', const Color(0xFF059669)),
                          const SizedBox(height: 10),
                          _buildLegendRow('Approved Leave', '5 Teachers (8%)', const Color(0xFFF59E0B)),
                          const SizedBox(height: 10),
                          _buildLegendRow('Unplanned Absent', '3 Teachers (4%)', const Color(0xFFDC2626)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        final studentCard = Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Student Attendance Rate (Institutional)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '94.2% Overall',
                        style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStudentRateBar('Class 10-A', 0.952, '40 / 42 Present (95.2%)', const Color(0xFF059669)),
                const SizedBox(height: 10),
                _buildStudentRateBar('Class 10-B', 0.925, '37 / 40 Present (92.5%)', const Color(0xFF2563EB)),
                const SizedBox(height: 10),
                _buildStudentRateBar('Class 9-A', 0.960, '39 / 41 Present (96.0%)', const Color(0xFF7C3AED)),
                const SizedBox(height: 10),
                _buildStudentRateBar('Class 9-B', 0.910, '36 / 39 Present (91.0%)', const Color(0xFFD97706)),
              ],
            ),
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: pieCard),
                    const SizedBox(width: 20),
                    Expanded(child: studentCard),
                  ],
                )
              : Column(
                  children: [
                    pieCard,
                    const SizedBox(height: 18),
                    studentCard,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildLegendRow(String title, String count, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(count, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildStudentRateBar(String className, double pct, String detail, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(className, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(detail, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: pct, backgroundColor: const Color(0xFFE2E8F0), color: color, minHeight: 8),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: TEACHER REGISTRY
  // ==========================================
  Widget _buildTeacherRegistryTab() {
    if (_isLoadingTeachers) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 550;
                  return isWide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Authorized Teacher & Faculty Directory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text('Total Faculty: ${_teachers.length} registered accounts', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: _showAddTeacherDialog,
                              icon: const Icon(Icons.person_add, size: 16),
                              label: const Text('Add Teacher ID'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Authorized Teacher & Faculty Directory', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text('Total Faculty: ${_teachers.length} registered accounts', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _showAddTeacherDialog,
                              icon: const Icon(Icons.person_add, size: 16),
                              label: const Text('Add Teacher ID'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        );
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _teachers.length,
                separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final t = _teachers[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF059669).withOpacity(0.12),
                      child: Text(t.name.isNotEmpty ? t.name[0].toUpperCase() : 'T', style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700)),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                          child: Text(t.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Google: ${t.emailOrPhone} • ${t.designation ?? 'Faculty'} • Classes: ${t.assignedClasses.join(', ')}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    trailing: t.id != 'USR_TEACHER_01'
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 20),
                            tooltip: 'Deactivate Teacher ID',
                            onPressed: () async {
                              await _registryService.deleteTeacher(t.id);
                              await _loadTeachers();
                            },
                          )
                        : const Chip(label: Text('Primary Faculty', style: TextStyle(fontSize: 10))),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: LEAVE CALENDAR & APPROVALS
  // ==========================================
  Widget _buildLeaveCalendarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Faculty Leave Applications & Calendar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Review, approve, or reject teacher leave submissions to maintain academic continuity.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const SizedBox(height: 16),
              const Divider(),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _leaveApplications.length,
                separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final item = _leaveApplications[index];
                  final isPending = item['status'] == 'Pending';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 600;
                        final actionButtons = isPending
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() => item['status'] = 'Rejected');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Leave rejected for ${item['teacherName']}')),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
                                    child: const Text('Reject'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() => item['status'] = 'Approved');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Leave approved for ${item['teacherName']}'), backgroundColor: const Color(0xFF16A34A)),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                                    child: const Text('Approve'),
                                  ),
                                ],
                              )
                            : Chip(
                                label: Text(item['status'] as String),
                                backgroundColor: const Color(0xFFECFDF5),
                                labelStyle: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700, fontSize: 12),
                              );

                        return isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isPending ? Icons.pending_actions : Icons.check_circle_outline,
                                      color: isPending ? const Color(0xFFD97706) : const Color(0xFF059669),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['teacherName'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                        const SizedBox(height: 2),
                                        Text('${item['type']} • ${item['dates']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 4),
                                        Text('Reason: ${item['reason']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  actionButtons,
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          isPending ? Icons.pending_actions : Icons.check_circle_outline,
                                          color: isPending ? const Color(0xFFD97706) : const Color(0xFF059669),
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item['teacherName'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                            const SizedBox(height: 2),
                                            Text('${item['type']} • ${item['dates']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                            const SizedBox(height: 4),
                                            Text('Reason: ${item['reason']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  actionButtons,
                                ],
                              );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 4: FEE LEDGER & UPI PAYMENT
  // ==========================================
  Widget _buildFeeLedgerTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 650;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI strip: side-by-side in landscape, stacked full-width in portrait
              isWide
                  ? Row(
                      children: [
                        Expanded(child: _buildKpiMiniCard('Total Billed Dues', '\$74,000', const Color(0xFF0F172A))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildKpiMiniCard('Collected via UPI / Cash', '\$47,000', const Color(0xFF16A34A))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildKpiMiniCard('Outstanding Balance', '\$27,000', const Color(0xFFDC2626))),
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(width: double.infinity, child: _buildKpiMiniCard('Total Billed Dues', '\$74,000', const Color(0xFF0F172A))),
                        const SizedBox(height: 10),
                        SizedBox(width: double.infinity, child: _buildKpiMiniCard('Collected via UPI / Cash', '\$47,000', const Color(0xFF16A34A))),
                        const SizedBox(height: 10),
                        SizedBox(width: double.infinity, child: _buildKpiMiniCard('Outstanding Balance', '\$27,000', const Color(0xFFDC2626))),
                      ],
                    ),
              const SizedBox(height: 20),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Student Fee Ledger & Digital UPI Collections', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      const Text('Directly collect tuition and laboratory dues using dynamic institutional UPI QR codes.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text('Student', style: TextStyle(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('Roll No')),
                            DataColumn(label: Text('Class')),
                            DataColumn(label: Text('Total')),
                            DataColumn(label: Text('Due')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: _feeLedger.map((item) {
                            final isDue = (item['dueAmount'] as int) > 0;
                            return DataRow(cells: [
                              DataCell(Text(item['studentName'] as String, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(item['rollNo'] as String)),
                              DataCell(Text(item['class'] as String)),
                              DataCell(Text('\$${item['totalFee']}')),
                              DataCell(Text('\$${item['dueAmount']}', style: TextStyle(color: isDue ? const Color(0xFFDC2626) : const Color(0xFF059669), fontWeight: FontWeight.w700))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDue ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['status'] as String,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDue ? const Color(0xFFDC2626) : const Color(0xFF059669)),
                                  ),
                                ),
                              ),
                              DataCell(
                                isDue
                                    ? ElevatedButton.icon(
                                        onPressed: () => _showUpiPaymentDialog(item),
                                        icon: const Icon(Icons.qr_code, size: 14),
                                        label: const Text('UPI Pay'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0F172A),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        ),
                                      )
                                    : const Icon(Icons.check_circle, color: Color(0xFF059669), size: 20),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiMiniCard(String title, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 5: CLASSROOM WATCH & HOMEWORK
  // ==========================================
  Widget _buildClassroomHomeworkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Flexible(
                child: Text('Live Classroom Operations & Structured Homework Vault', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              SizedBox(width: 8),
              Chip(label: Text('3 In Session', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11))),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Monitor active classroom topics and review all assigned homework documents across classes.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 18),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _classroomHomework.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final hw = _classroomHomework[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(6)),
                                child: Text(hw['class'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Text('${hw['subject']} • Faculty: ${hw['teacher']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
                            child: Text(hw['submissions'] as String, style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.play_circle_fill, size: 16, color: Color(0xFF059669)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('Currently Running Topic: ${hw['runningTopic']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Assigned Homework: ${hw['homeworkTitle']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A))),
                      const SizedBox(height: 14),
                      // Document Attachment Button
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showDocumentViewerDialog(hw),
                            icon: const Icon(Icons.description, size: 16),
                            label: Text('Open ${hw['docTitle']} (Document Viewer)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                          Text('Due: ${hw['dueDate']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 6: EXAM ARCHIVE & REPORTS
  // ==========================================
  Widget _buildExamArchiveTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 550;
                  return isWide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Examination Terms & Signed Report Cards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                SizedBox(height: 2),
                                Text('Term Assessments, GPA validation, and digital certificate verification.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: _showReportCardDialog,
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text('View Signed Sample Card'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD97706),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Examination Terms & Signed Report Cards', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            const Text('Term Assessments, GPA validation, and digital certificate verification.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _showReportCardDialog,
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text('View Signed Sample Card'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD97706),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        );
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Exam Term', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Class & Batch')),
                    DataColumn(label: Text('Pass %')),
                    DataColumn(label: Text('Top GPA')),
                    DataColumn(label: Text('Certification Status')),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('Term 1 Summative Assessment', style: TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text('Class 10 (All Sections)')),
                      DataCell(Text('98.4%', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700))),
                      DataCell(Text('9.80')),
                      DataCell(Chip(label: Text('Signed & Published', style: TextStyle(fontSize: 11)), backgroundColor: Color(0xFFECFDF5))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Unit Test 2 (Mid-Semester)', style: TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text('Class 9 (All Sections)')),
                      DataCell(Text('96.1%', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700))),
                      DataCell(Text('9.65')),
                      DataCell(Chip(label: Text('Signed & Published', style: TextStyle(fontSize: 11)), backgroundColor: Color(0xFFECFDF5))),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Teacher Attendance Rate Pie Chart
class _PieChartPainter extends CustomPainter {
  final double presentPct;
  final double leavePct;
  final double absentPct;

  _PieChartPainter({
    required this.presentPct,
    required this.leavePct,
    required this.absentPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;

    // Present Slice
    final presentAngle = presentPct * 2 * math.pi;
    final presentPaint = Paint()..color = const Color(0xFF059669);
    canvas.drawArc(rect, startAngle, presentAngle, true, presentPaint);
    startAngle += presentAngle;

    // Leave Slice
    final leaveAngle = leavePct * 2 * math.pi;
    final leavePaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawArc(rect, startAngle, leaveAngle, true, leavePaint);
    startAngle += leaveAngle;

    // Absent Slice
    final absentAngle = absentPct * 2 * math.pi;
    final absentPaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawArc(rect, startAngle, absentAngle, true, absentPaint);

    // Inner Hole for Donut Look
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
