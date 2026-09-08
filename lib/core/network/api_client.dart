import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

/// Centralized Dio HTTP Client wrapper with logging, custom timeouts, and security interceptors
class ApiClient {
  late final Dio dio;

  ApiClient({
    required SecureStorageService storageService,
    void Function()? onSessionExpired,
    String baseUrl = ApiEndpoints.baseUrl,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.connectTimeout,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(
        storageService: storageService,
        onSessionExpired: onSessionExpired,
      ),
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    ]);
  }
}
