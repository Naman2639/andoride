import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

/// Dio Interceptor that automatically injects JWT Bearer tokens,
/// records network activity for session tracking, and handles 401 unauthenticated signals.
class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _storageService;
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required SecureStorageService storageService,
    this.onSessionExpired,
  }) : _storageService = storageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Record activity timestamp for active session
    await _storageService.recordActiveTimestamp();

    // Check if path is public (e.g. login, otp)
    final isPublic = options.path.contains('/auth/login') ||
        options.path.contains('/auth/otp');

    if (!isPublic) {
      final token = await _storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token invalid or session expired on server side
      await _storageService.clearAll();
      onSessionExpired?.call();
    }
    return handler.next(err);
  }
}
