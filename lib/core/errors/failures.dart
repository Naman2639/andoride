import 'package:equatable/equatable.dart';

/// Base Failure class to map clean errors up to the Presentation layer
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'Session timed out. Please authenticate again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection unavailable. Please check your internet.']);
}
