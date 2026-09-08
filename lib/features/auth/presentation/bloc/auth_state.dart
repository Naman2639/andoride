import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Async operations underway (signing in, verifying OTP, etc.)
class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// OTP successfully dispatched to user's phone / email
class OtpSentState extends AuthState {
  final String identifier;
  const OtpSentState({required this.identifier});

  @override
  List<Object?> get props => [identifier];
}

/// Successfully authenticated with active user profile and verified role
class Authenticated extends AuthState {
  final User user;
  const Authenticated({required this.user});

  UserRole get role => user.role;

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state (logged out, initial state, or timed out)
class Unauthenticated extends AuthState {
  final String? message;
  final bool isSessionTimeout;

  const Unauthenticated({
    this.message,
    this.isSessionTimeout = false,
  });

  @override
  List<Object?> get props => [message, isSessionTimeout];
}

/// Authentication failure with user-friendly error message
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
