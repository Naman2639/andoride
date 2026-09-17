import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/user_registry_service.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_role.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  final String? sessionMessage;
  const LoginScreen({super.key, this.sessionMessage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  late final UserRegistryService _registryService;
  List<UserModel> _availableGoogleProfiles = [];
  bool _isLoadingProfiles = true;

  @override
  void initState() {
    super.initState();
    _registryService = UserRegistryService(storageService: SecureStorageService());
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final teachers = await _registryService.getAllTeachers();
    final students = await _registryService.getAllStudents();
    final defaults = _registryService.getDemoGoogleProfiles();

    final all = <UserModel>[...defaults];
    for (final t in teachers) {
      if (!all.any((u) => u.emailOrPhone.toLowerCase() == t.emailOrPhone.toLowerCase())) {
        all.add(t);
      }
    }
    for (final s in students) {
      if (!all.any((u) => u.emailOrPhone.toLowerCase() == s.emailOrPhone.toLowerCase())) {
        all.add(s);
      }
    }

    if (mounted) {
      setState(() {
        _availableGoogleProfiles = all;
        _isLoadingProfiles = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _signInWithGoogle(String email, {String? displayName}) {
    context.read<AuthBloc>().add(
          GoogleSignInSubmitted(
            email: email.trim(),
            displayName: displayName,
          ),
        );
  }

  void _showGoogleAccountPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildGoogleLogo(size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Choose a Google Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Select an enrolled institutional Google Account to continue to EduGovernance ERP',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),

              // List of recognized school accounts
              if (_isLoadingProfiles)
                const Center(child: CircularProgressIndicator())
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _availableGoogleProfiles.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final profile = _availableGoogleProfiles[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(profile.role).withOpacity(0.15),
                          child: Text(
                            profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'G',
                            style: TextStyle(
                              color: _getRoleColor(profile.role),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getRoleColor(profile.role).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                profile.role.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _getRoleColor(profile.role),
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          profile.emailOrPhone,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
                        onTap: () {
                          Navigator.pop(context);
                          _signInWithGoogle(profile.emailOrPhone, displayName: profile.name);
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Use another account button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showCustomEmailDialog();
                },
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text('Use another Google Account'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomEmailDialog() {
    _emailController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              _buildGoogleLogo(size: 22),
              const SizedBox(width: 10),
              const Text('Google Sign-In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your registered Google Email account (@gmail.com or institutional domain):',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Google Email',
                  hintText: 'e.g. name@gmail.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  Navigator.pop(context);
                  _signInWithGoogle(email);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFFD97706);
      case UserRole.teacher:
        return const Color(0xFF059669);
      case UserRole.student:
        return const Color(0xFF0284C7);
      case UserRole.parent:
        return const Color(0xFF4F46E5);
    }
  }

  Widget _buildGoogleLogo({double size = 20}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: size * 0.9,
            fontWeight: FontWeight.w900,
            fontFamily: 'Roboto',
            color: const Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              icon: const Icon(Icons.gpp_maybe, size: 42, color: Color(0xFFDC2626)),
              title: const Text(
                'Authorization Required',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              content: Text(
                state.message,
                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Understood'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Branding Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        size: 46,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'EduGovernance ERP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Unified Enterprise School Governance & Identity Gateway',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Session message banner if applicable
                  if (widget.sessionMessage != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_clock, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.sessionMessage!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF991B1B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Main Card: Google Sign-In Only
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.security, size: 20, color: Color(0xFF4F46E5)),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Google Single Sign-On',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Sign in with your verified Google Account. Access permissions and portals are determined by your registered institutional role.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                          ),
                          const SizedBox(height: 24),

                          // Google Sign-In Primary Action Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;

                              return OutlinedButton(
                                onPressed: isLoading ? null : _showGoogleAccountPicker,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0F172A),
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 1,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _buildGoogleLogo(size: 22),
                                          const SizedBox(width: 14),
                                          const Text(
                                            'Sign in with Google',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.2,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Role Governance Policy Note
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'RBAC ACCESS RULES',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '• Admin creates & authorizes Teacher IDs.\n'
                                  '• Teachers enroll & assign Student IDs.\n'
                                  '• Only enrolled Google Accounts can log in.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick One-Tap Switcher for instant demonstration
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ONE-TAP DEMO GOOGLE ACCOUNTS',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildQuickChip(
                              name: 'Dr. Vance',
                              roleText: 'Admin',
                              email: 'admin.school@gmail.com',
                              color: const Color(0xFF0F172A),
                            ),
                            _buildQuickChip(
                              name: 'Sarah Jenkins',
                              roleText: 'Teacher',
                              email: 'teacher.sarah@gmail.com',
                              color: const Color(0xFF065F46),
                            ),
                            _buildQuickChip(
                              name: 'Alex Rivera',
                              roleText: 'Student',
                              email: 'student.alex@gmail.com',
                              color: const Color(0xFF0284C7),
                            ),
                            _buildQuickChip(
                              name: 'Scott Family',
                              roleText: 'Parent',
                              email: 'parent.scott@gmail.com',
                              color: const Color(0xFF312E81),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip({
    required String name,
    required String roleText,
    required String email,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _signInWithGoogle(email, displayName: name),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGoogleLogo(size: 14),
            const SizedBox(width: 8),
            Text(
              '$name ($roleText)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
