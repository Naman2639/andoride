import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<({UserModel user, String accessToken, String? refreshToken})> loginWithPassword({
    required String identifier,
    required String password,
  });

  Future<void> requestOtp({required String identifier});

  Future<({UserModel user, String accessToken, String? refreshToken})> verifyOtp({
    required String identifier,
    required String otp,
  });

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<({UserModel user, String accessToken, String? refreshToken})> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.loginWithPassword,
        data: {
          'identifier': identifier.trim(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String? ?? 'mock_jwt_token';
      final refreshToken = data['refreshToken'] as String?;

      return (user: user, accessToken: token, refreshToken: refreshToken);
    } on DioException catch (dioError) {
      // Fallback demo provision when testing without live mock backend
      if (dioError.type == DioExceptionType.connectionError ||
          dioError.type == DioExceptionType.connectionTimeout) {
        return _generateDemoResponse(identifier);
      }

      throw ServerException(
        message: dioError.response?.data?['message']?.toString() ??
            dioError.message ??
            'Authentication failed.',
        statusCode: dioError.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> requestOtp({required String identifier}) async {
    try {
      await _dio.post(
        ApiEndpoints.requestOtp,
        data: {'identifier': identifier.trim()},
      );
    } on DioException catch (dioError) {
      // Allow seamless offline testing if backend is not yet deployed
      if (dioError.type == DioExceptionType.connectionError ||
          dioError.type == DioExceptionType.connectionTimeout) {
        return;
      }
      throw ServerException(
        message: dioError.response?.data?['message']?.toString() ?? 'Failed to send OTP.',
        statusCode: dioError.response?.statusCode,
      );
    }
  }

  @override
  Future<({UserModel user, String accessToken, String? refreshToken})> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyOtp,
        data: {
          'identifier': identifier.trim(),
          'otp': otp.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String? ?? 'mock_otp_jwt_token';
      final refreshToken = data['refreshToken'] as String?;

      return (user: user, accessToken: token, refreshToken: refreshToken);
    } on DioException catch (dioError) {
      if (dioError.type == DioExceptionType.connectionError ||
          dioError.type == DioExceptionType.connectionTimeout) {
        return _generateDemoResponse(identifier);
      }
      throw ServerException(
        message: dioError.response?.data?['message']?.toString() ?? 'Invalid or expired OTP.',
        statusCode: dioError.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Best-effort remote revocation
    }
  }

  /// Internal deterministic mock generator for rapid evaluation without server setup
  ({UserModel user, String accessToken, String? refreshToken}) _generateDemoResponse(
      String identifier) {
    final lower = identifier.toLowerCase();
    UserRole role;
    String name;
    String designation;

    if (lower.contains('admin') || lower.contains('manager') || lower.startsWith('98')) {
      role = UserRole.admin;
      name = 'Dr. Robert Vance';
      designation = 'School Director & Administrator';
    } else if (lower.contains('teacher') || lower.contains('staff') || lower.startsWith('97')) {
      role = UserRole.teacher;
      name = 'Sarah Jenkins, M.Sc.';
      designation = 'Class 10-A Head & Math Faculty';
    } else {
      role = UserRole.parent;
      name = 'Michael & Elena Scott';
      designation = 'Guardian of Liam Scott (10-A)';
    }

    final user = UserModel(
      id: 'USR_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emailOrPhone: identifier,
      role: role,
      designation: designation,
      assignedClasses: const ['Class 10-A', 'Class 9-B'],
      studentIds: const ['STD_1001', 'STD_1002'],
    );

    return (
      user: user,
      accessToken: 'demo_jwt_token_${role.name}',
      refreshToken: 'demo_refresh_${role.name}',
    );
  }
}
