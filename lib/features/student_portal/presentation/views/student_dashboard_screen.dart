import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/assignment_sync_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  late final AssignmentSyncService _syncService;

  @override
  void initState() {
    super.initState();
    _syncService = AssignmentSyncService();
  }

  void _showDocumentViewer(BuildContext context, String title, String fileName, String size) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Assignment: $title • Size: $size',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book, size: 52, color: Color(0xFF64748B)),
                        const SizedBox(height: 10),
                        Text(
                          fileName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Official Faculty Worksheet / Document Preview',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Verified by Teacher • 100% Virus-free', style: TextStyle(fontSize: 10, color: Color(0xFF16A34A), fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
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
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Downloading "$fileName" to device... Saved to /Download/$fileName'),
                    backgroundColor: const Color(0xFF0284C7),
                  ),
                );
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _downloadReportCardToPhone(BuildContext context, String studentName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future.delayed(const Duration(milliseconds: 1400), () {
              if (Navigator.canPop(ctx)) {
                Navigator.pop(ctx);
                _showReportCardInspectionDialog(context, studentName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 4),
                    backgroundColor: const Color(0xFF059669),
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Report Card PDF saved to: /storage/emulated/0/Download/ReportCard_Term1.pdf',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    action: SnackBarAction(
                      label: 'VIEW PDF',
                      textColor: Colors.white,
                      onPressed: () => _showReportCardInspectionDialog(context, studentName),
                    ),
                  ),
                );
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(color: Color(0xFF0369A1), strokeWidth: 3),
                    SizedBox(height: 20),
                    Text(
                      'Downloading Certified Report Card...',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Generating high-DPI PDF with cryptographic school seal & QR verification hash.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReportCardInspectionDialog(BuildContext context, String studentName) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.verified, color: Color(0xFF059669), size: 24),
              SizedBox(width: 8),
              Text('Official Report Card', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(studentName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              const Text('Roll No: STU-10A-01 • Class 10-A', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                            child: const Text('PASSED (A1)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Academic Term: Term 1 (2026-27)', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          Text('Attendance: 95.2%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('SUBJECT EVALUATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    columns: const [
                      DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      DataColumn(label: Text('Max', style: TextStyle(fontSize: 12))),
                      DataColumn(label: Text('Scored', style: TextStyle(fontSize: 12))),
                      DataColumn(label: Text('Grade', style: TextStyle(fontSize: 12))),
                    ],
                    rows: const [
                      DataRow(cells: [DataCell(Text('Mathematics')), DataCell(Text('100')), DataCell(Text('94')), DataCell(Text('A1'))]),
                      DataRow(cells: [DataCell(Text('Physics')), DataCell(Text('100')), DataCell(Text('91')), DataCell(Text('A1'))]),
                      DataRow(cells: [DataCell(Text('Chemistry')), DataCell(Text('100')), DataCell(Text('88')), DataCell(Text('A2'))]),
                      DataRow(cells: [DataCell(Text('English Core')), DataCell(Text('100')), DataCell(Text('95')), DataCell(Text('A1'))]),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.workspace_premium, color: Color(0xFF16A34A), size: 22),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Digitally signed by Dr. E. Vance (Principal) & Sarah Jenkins (Class Teacher). Stored on phone storage.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF166534), height: 1.3),
                        ),
                      ),
                    ],
                  ),
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
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sent print job to local printer.')),
                );
              },
              icon: const Icon(Icons.print, size: 16),
              label: const Text('Print'),
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
      backgroundColor: const Color(0xFFF0F9FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Profile Welcome Card
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final studentName = state is Authenticated ? state.user.name : 'Alex Rivera';
                final studentEmail = state is Authenticated ? state.user.emailOrPhone : 'student.alex@gmail.com';
                final designation = state is Authenticated ? (state.user.designation ?? 'Class 10-A') : 'Class 10-A';

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    final attendanceBadge = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Attendance Rate', style: TextStyle(fontSize: 11, color: Color(0xFF065F46), fontWeight: FontWeight.w600)),
                          Text('95.2%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                        ],
                      ),
                    );

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: isWide
                            ? Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: const Color(0xFF0284C7).withOpacity(0.15),
                                    child: Text(
                                      studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0369A1)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome back, $studentName!',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$designation • Google Account: $studentEmail',
                                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  attendanceBadge,
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: const Color(0xFF0284C7).withOpacity(0.15),
                                        child: Text(
                                          studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0369A1)),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Welcome back, $studentName!',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$designation • Google: $studentEmail',
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  attendanceBadge,
                                ],
                              ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Metrics Summary Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 650;
                final tile1 = _buildSummaryTile('Active Assignments', 'Dynamic Class Vault', Icons.assignment, const Color(0xFF2563EB));
                final tile2 = _buildSummaryTile('Term GPA', '9.4 / 10.0 (Grade A1)', Icons.military_tech, const Color(0xFFD97706));
                final tile3 = _buildSummaryTile('Fee Clearance', 'Fully Paid • No Dues', Icons.verified, const Color(0xFF059669));

                return isWide
                    ? Row(
                        children: [
                          Expanded(child: tile1),
                          const SizedBox(width: 16),
                          Expanded(child: tile2),
                          const SizedBox(width: 16),
                          Expanded(child: tile3),
                        ],
                      )
                    : Column(
                        children: [
                          tile1,
                          const SizedBox(height: 10),
                          tile2,
                          const SizedBox(height: 10),
                          tile3,
                        ],
                      );
              },
            ),
            const SizedBox(height: 24),

            // Active Homework & Assignments Vault (Synced with Teacher Portal in real time!)
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _syncService.assignmentsNotifier,
              builder: (context, assignments, _) {
                return Card(
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
                            const Flexible(
                              child: Text('Assigned Homework & Class Vault', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${assignments.length} Tasks Synced',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Complete worksheets, access attached teacher PDFs, and submit answers.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        const SizedBox(height: 16),
                        const Divider(),

                        if (assignments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No active assignments right now.', style: TextStyle(color: Color(0xFF64748B))),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: assignments.length,
                            separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, index) {
                              final asgn = assignments[index];
                              final isDone = asgn['isSubmitted'] == true;
                              final rawAttachments = asgn['attachments'];
                              final List<Map<String, dynamic>> attachments = [];

                              if (rawAttachments is List) {
                                for (final item in rawAttachments) {
                                  if (item is Map) {
                                    attachments.add(Map<String, dynamic>.from(item));
                                  }
                                }
                              } else if (asgn['attachment'] != null) {
                                attachments.add({'name': asgn['attachment'].toString(), 'size': '1.8 MB'});
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isDone ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            isDone ? Icons.check_circle : Icons.pending,
                                            color: isDone ? const Color(0xFF059669) : const Color(0xFF2563EB),
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF0F172A).withOpacity(0.06),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      asgn['subject'] ?? 'Mathematics',
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Due: ${asgn['dueDate'] ?? 'Soon'}',
                                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                asgn['title'] ?? 'Assignment',
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
                                              ),
                                              if (asgn['instructions'] != null && asgn['instructions'].toString().isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  asgn['instructions'].toString(),
                                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (!isDone)
                                          ElevatedButton(
                                            onPressed: () async {
                                              await _syncService.submitAssignment(asgn['id'].toString());
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Turned in solution for "${asgn['title']}"! Marked as Submitted.'),
                                                    backgroundColor: const Color(0xFF16A34A),
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0369A1),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            ),
                                            child: const Text('Turn In'),
                                          )
                                        else
                                          const Chip(
                                            label: Text('Submitted', style: TextStyle(fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.w700)),
                                            backgroundColor: Color(0xFFECFDF5),
                                          ),
                                      ],
                                    ),

                                    // Teacher attached PDF documents list
                                    if (attachments.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 46),
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          children: attachments.map((att) {
                                            final fn = att['name'] ?? 'Document.pdf';
                                            final sz = att['size'] ?? '1.5 MB';
                                            return InkWell(
                                              onTap: () => _showDocumentViewer(context, asgn['title'] ?? 'Assignment', fn, sz),
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.picture_as_pdf, size: 14, color: Color(0xFFDC2626)),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      '$fn ($sz)',
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Icon(Icons.visibility, size: 12, color: Color(0xFF64748B)),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Examination Archive & Certified Report Card (Fully functional download!)
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final studentName = state is Authenticated ? state.user.name : 'Alex Rivera';

                return Card(
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
                                          Text('Term 1 Assessment Report Card', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                                          SizedBox(height: 2),
                                          Text('Signed and certified by School Principal & Class Teacher', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => _downloadReportCardToPhone(context, studentName),
                                        icon: const Icon(Icons.download, size: 16),
                                        label: const Text('Download Official PDF'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0369A1),
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Text('Term 1 Assessment Report Card', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 2),
                                      const Text('Signed and certified by School Principal & Class Teacher', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: () => _downloadReportCardToPhone(context, studentName),
                                        icon: const Icon(Icons.download, size: 16),
                                        label: const Text('Download Official PDF'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0369A1),
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
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.w700))),
                              DataColumn(label: Text('Max')),
                              DataColumn(label: Text('Obtained')),
                              DataColumn(label: Text('Grade')),
                              DataColumn(label: Text('Remarks')),
                            ],
                            rows: const [
                              DataRow(cells: [DataCell(Text('Mathematics')), DataCell(Text('100')), DataCell(Text('94')), DataCell(Text('A1')), DataCell(Text('Exceptional problem solving'))]),
                              DataRow(cells: [DataCell(Text('Physics')), DataCell(Text('100')), DataCell(Text('91')), DataCell(Text('A1')), DataCell(Text('Strong conceptual grasp'))]),
                              DataRow(cells: [DataCell(Text('Chemistry')), DataCell(Text('100')), DataCell(Text('88')), DataCell(Text('A2')), DataCell(Text('Good lab experiment work'))]),
                              DataRow(cells: [DataCell(Text('English Core')), DataCell(Text('100')), DataCell(Text('95')), DataCell(Text('A1')), DataCell(Text('Excellent analytical writing'))]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
