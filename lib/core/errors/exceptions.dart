/// Custom domain exceptions for data layer failure mapping
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class SessionExpiredException implements Exception {
  final String message;
  const SessionExpiredException({this.message = 'Your session has expired for security.'});

  @override
  String toString() => 'SessionExpiredException: $message';
}

class UnauthorizedRoleException implements Exception {
  final String message;
  const UnauthorizedRoleException({this.message = 'Account lacks permissions for this portal.'});

  @override
  String toString() => 'UnauthorizedRoleException: $message';
}
