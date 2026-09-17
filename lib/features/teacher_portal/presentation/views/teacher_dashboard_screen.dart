import 'package:flutter/material.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../auth/data/datasources/user_registry_service.dart';
import '../../../auth/data/models/user_model.dart';

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
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assigned Class Info Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                        size: 32,
                        color: Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_selectedClass • Morning Session',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enrolled Students: ${_students.length} • Attendance Status: Marked Present',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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

            // Student Roster Management Card
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
            const SizedBox(height: 24),

            // Daily Classroom Operations
            const Text(
              'Daily Classroom Operations',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF065F46),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    title: 'One-Tap Attendance',
                    subtitle: 'Alphabetical roll call. Default "All Present". Tap absentees.',
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF059669),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Attendance register marked and synced for today!'), backgroundColor: Color(0xFF16A34A)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionTile(
                    title: 'Publish Assignment / Homework',
                    subtitle: 'Post problem sets, reading assignments, and due dates.',
                    icon: Icons.assignment_turned_in_outlined,
                    iconColor: const Color(0xFF2563EB),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Homework published to Class 10-A Student Vault!')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    title: 'Enter Term Marks & Observations',
                    subtitle: 'Theory, practical, and internal assessment entries.',
                    icon: Icons.grading,
                    iconColor: const Color(0xFFD97706),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Term Marks entry gate opened for Class 10-A')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionTile(
                    title: 'Attendance Correction Window',
                    subtitle: 'Adjust accidental mis-marks within designated grace period.',
                    icon: Icons.edit_calendar_outlined,
                    iconColor: const Color(0xFF7C3AED),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
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
                child: Icon(icon, size: 24, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}
