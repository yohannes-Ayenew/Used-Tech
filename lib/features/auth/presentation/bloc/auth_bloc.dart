// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';
import '../../domain/usecases/verify_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final SignupUser signupUser;
  final VerifyOtp verifyOtp;
  final CheckAuthStatus checkAuthStatus;

  AuthBloc({
    required this.loginUser,
    required this.signupUser,
    required this.verifyOtp,
    required this.checkAuthStatus,
  }) : super(AuthInitial()) {
    on<LoginRequestedEvent>(_onLoginRequested);
    on<SignupRequestedEvent>(_onSignupRequested);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<AppStartedEvent>(_onAppStarted);
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUser(event.email, event.password);
    result.fold((failure) => emit(AuthFailure(failure.message)), (data) {
      // data is Map<String, dynamic> with 'user' and 'token'
      emit(AuthSuccess(data['user'], token: data['token']));
    });
  }

  Future<void> _onSignupRequested(
    SignupRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signupUser(
      name: event.name,
      email: event.email,
      phone: event.phone,
      password: event.password,
    );
    result.fold((failure) => emit(AuthFailure(failure.message)), (data) {
      // data is Map<String, dynamic> with 'userId' and 'message'
      emit(OtpRequiredState(userId: data['userId'], message: data['message']));
    });
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await verifyOtp(event.userId, event.otp);
    result.fold((failure) => emit(AuthFailure(failure.message)), (data) {
      // data is Map<String, dynamic> with 'user' and 'token'
      emit(OtpVerifiedState(data['user'], token: data['token']));
    });
  }

  Future<void> _onAppStarted(
    AppStartedEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await checkAuthStatus();
    result.fold((failure) => emit(AuthGuest()), (user) {
      // user is UserEntity
      emit(AuthSuccess(user, token: user.token));
    });
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Clear token from local storage
      // You'll need to inject AuthLocalDataSource here or create a logout use case
      // For now, just emit guest state
      emit(AuthGuest());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
