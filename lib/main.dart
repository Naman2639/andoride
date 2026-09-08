import 'package:flutter/material.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/session/session_manager.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Local Secure Storage
  final storageService = SecureStorageService();

  // 2. Initialize Role-Based Session Tracker
  late final SessionManager sessionManager;

  // 3. Initialize Network Client with Auth Interceptor
  final apiClient = ApiClient(
    storageService: storageService,
    onSessionExpired: () {
      // Automatic remote 401 unauthenticated callback
    },
  );

  // 4. Instantiate Remote & Local Data Sources
  final remoteDataSource = AuthRemoteDataSourceImpl(dio: apiClient.dio);
  final localDataSource = AuthLocalDataSourceImpl(storageService: storageService);

  // 5. Initialize Auth Bloc placeholder to wire session callbacks
  late final AuthBloc authBloc;

  sessionManager = SessionManager(
    storageService: storageService,
    onSessionTimedOut: () {
      authBloc.add(const SessionTimedOut());
    },
  );

  // 6. Instantiate Auth Repository
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    sessionManager: sessionManager,
  );

  // 7. Initialize Auth BLoC & Dispatch Initial State Check
  authBloc = AuthBloc(
    authRepository: authRepository,
    sessionManager: sessionManager,
  )..add(const AppStarted());

  // 8. Configure Declarative GoRouter with RBAC Redirect Guards
  final router = AppRouter.createRouter(authBloc);

  runApp(
    EduGovernanceApp(
      authBloc: authBloc,
      router: router,
    ),
  );
}
