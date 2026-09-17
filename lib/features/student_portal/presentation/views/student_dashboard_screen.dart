import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

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

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Column(
                            children: const [
                              Text('Attendance Rate', style: TextStyle(fontSize: 11, color: Color(0xFF065F46), fontWeight: FontWeight.w600)),
                              Text('95.2%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Metrics Summary Grid
            Row(
              children: [
                _buildSummaryTile('Active Assignments', '3 Due This Week', Icons.assignment, const Color(0xFF2563EB)),
                const SizedBox(width: 16),
                _buildSummaryTile('Term GPA', '9.4 / 10.0 (Grade A1)', Icons.military_tech, const Color(0xFFD97706)),
                const SizedBox(width: 16),
                _buildSummaryTile('Fee Clearance', 'Fully Paid • No Dues', Icons.verified, const Color(0xFF059669)),
              ],
            ),
            const SizedBox(height: 24),

            // Active Homework & Assignments Vault
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
                      children: const [
                        Text('Assigned Homework & Class Tasks', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        Chip(label: Text('Class 10-A Vault', style: TextStyle(fontSize: 11))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Complete worksheets, submit answers, and track teacher reviews.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    const SizedBox(height: 16),
                    const Divider(),

                    _buildHomeworkRow(
                      context,
                      subject: 'Mathematics',
                      title: 'Quadratic Equations Exercise 4.3 Word Problems',
                      due: 'Tomorrow, 9:00 AM',
                      status: 'Pending Submission',
                      isDone: false,
                    ),
                    const Divider(color: Color(0xFFF1F5F9)),
                    _buildHomeworkRow(
                      context,
                      subject: 'Physics',
                      title: 'Ray Optics: Refraction Diagram & Index Calculation',
                      due: 'Friday, 11:30 AM',
                      status: 'Pending Submission',
                      isDone: false,
                    ),
                    const Divider(color: Color(0xFFF1F5F9)),
                    _buildHomeworkRow(
                      context,
                      subject: 'English Literature',
                      title: 'Robert Frost "The Road Not Taken" Essay Critique',
                      due: 'Yesterday',
                      status: 'Turned In • Graded A1',
                      isDone: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Examination Archive & Certified Report Card
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
                          children: const [
                            Text('Term 1 Assessment Report Card', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            SizedBox(height: 2),
                            Text('Signed and certified by School Principal & Class Teacher', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Report Card PDF downloaded successfully!')),
                            );
                          },
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Download Official PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0369A1),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    DataTable(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
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
      ),
    );
  }

  Widget _buildHomeworkRow(
    BuildContext context, {
    required String subject,
    required String title,
    required String due,
    required String status,
    required bool isDone,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
                Text('$subject: $title', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text('Due: $due • Status: $status', style: TextStyle(fontSize: 12, color: isDone ? const Color(0xFF059669) : const Color(0xFF64748B))),
              ],
            ),
          ),
          if (!isDone)
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Uploaded solution for $subject! Marked as Submitted.'), backgroundColor: const Color(0xFF16A34A)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0369A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Text('Turn In'),
            )
          else
            const Chip(label: Text('Submitted', style: TextStyle(fontSize: 10, color: Color(0xFF059669))), backgroundColor: Color(0xFFECFDF5)),
        ],
      ),
    );
  }
}
