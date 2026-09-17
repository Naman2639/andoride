import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AdminShellScreen extends StatefulWidget {
  final Widget child;
  const AdminShellScreen({super.key, required this.child});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  Timer? _countdownTimer;
  int _secondsRemaining = 15 * 60; // 15 mins for Admin inactivity policy

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        context.read<AuthBloc>().add(const SessionTimedOut());
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _resetInactivity() {
    setState(() {
      _secondsRemaining = 15 * 60;
    });
    context.read<AuthBloc>().add(const UserActivityRecorded());
  }

  String _formatTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetInactivity(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Governance Hub',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          actions: [
            // Session integrity countdown badge
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _secondsRemaining < 120
                      ? const Color(0xFFEF4444)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: _secondsRemaining < 120
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFFBBF24),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimer(_secondsRemaining),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _secondsRemaining < 120
                          ? const Color(0xFFEF4444)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            MediaQuery.of(context).size.width >= 600
                ? BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final userName = state is Authenticated ? state.user.name : 'Admin';
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Center(
                          child: Text(
                            userName,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            IconButton(
              icon: const Icon(Icons.logout, size: 20),
              tooltip: 'Sign Out',
              onPressed: () => context.read<AuthBloc>().add(const LogoutRequested()),
            ),
          ],
        ),
        body: widget.child,
      ),
    );
  }
}
