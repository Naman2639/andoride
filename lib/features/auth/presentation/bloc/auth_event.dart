import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched upon application launch to restore cached session
class AppStarted extends AuthEvent {
  const AppStarted();
}

/// Dispatched when authenticating via Google Account
class GoogleSignInSubmitted extends AuthEvent {
  final String email;
  final String? displayName;

  const GoogleSignInSubmitted({
    required this.email,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, displayName];
}

/// Dispatched when submitting Mobile/Email + Password
class LoginSubmitted extends AuthEvent {
  final String identifier;
  final String password;

  const LoginSubmitted({
    required this.identifier,
    required this.password,
  });

  @override
  List<Object?> get props => [identifier, password];
}

/// Dispatched when requesting an OTP to phone/email
class OtpRequested extends AuthEvent {
  final String identifier;

  const OtpRequested({required this.identifier});

  @override
  List<Object?> get props => [identifier];
}

/// Dispatched when verifying submitted OTP
class OtpVerified extends AuthEvent {
  final String identifier;
  final String otp;

  const OtpVerified({
    required this.identifier,
    required this.otp,
  });

  @override
  List<Object?> get props => [identifier, otp];
}

/// Dispatched to refresh active user session activity
class UserActivityRecorded extends AuthEvent {
  const UserActivityRecorded();
}

/// Dispatched when an admin or sensitive session runs out of time
class SessionTimedOut extends AuthEvent {
  const SessionTimedOut();
}

/// Dispatched when the user taps sign out
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
