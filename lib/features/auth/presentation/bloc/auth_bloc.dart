import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SessionManager _sessionManager;

  AuthBloc({
    required AuthRepository authRepository,
    required SessionManager sessionManager,
  })  : _authRepository = authRepository,
        _sessionManager = sessionManager,
        super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<GoogleSignInSubmitted>(_onGoogleSignInSubmitted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<OtpRequested>(_onOtpRequested);
    on<OtpVerified>(_onOtpVerified);
    on<UserActivityRecorded>(_onUserActivityRecorded);
    on<SessionTimedOut>(_onSessionTimedOut);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onGoogleSignInSubmitted(
    GoogleSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Verifying Google Account with School Records...'));
    try {
      final user = await _authRepository.loginWithGoogle(
        email: event.email,
        displayName: event.displayName,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(message: 'Verifying session...'));
    try {
      final user = await _authRepository.checkAuthStatus();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(message: 'Authenticating credentials...'));
    try {
      final user = await _authRepository.loginWithPassword(
        identifier: event.identifier,
        password: event.password,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onOtpRequested(OtpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(message: 'Dispatching OTP...'));
    try {
      await _authRepository.requestOtp(identifier: event.identifier);
      emit(OtpSentState(identifier: event.identifier));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onOtpVerified(OtpVerified event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(message: 'Verifying security token...'));
    try {
      final user = await _authRepository.verifyOtp(
        identifier: event.identifier,
        otp: event.otp,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUserActivityRecorded(
    UserActivityRecorded event,
    Emitter<AuthState> emit,
  ) async {
    await _sessionManager.recordUserActivity();
  }

  Future<void> _onSessionTimedOut(
    SessionTimedOut event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const Unauthenticated(
      isSessionTimeout: true,
      message: 'Administrative session timed out due to inactivity to protect records.',
    ));
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing out...'));
    await _authRepository.logout();
    emit(const Unauthenticated());
  }
}
