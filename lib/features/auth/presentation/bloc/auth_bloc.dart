// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';
import '../../domain/usecases/verify_email.dart';
import '../../domain/usecases/resend_otp.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/reset_password.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final SignupUser signupUser;
  final VerifyEmail verifyEmail;
  final ResendOTP resendOTP;
  final CheckAuthStatus checkAuthStatus;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;

  AuthBloc({
    required this.loginUser,
    required this.signupUser,
    required this.verifyEmail,
    required this.resendOTP,
    required this.checkAuthStatus,
    required this.forgotPassword,
    required this.resetPassword,
  }) : super(AuthInitial()) {
    on<SignupRequestedEvent>(_onSignupRequested);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<LoginRequestedEvent>(_onLoginRequested);
    on<ResendOTPEvent>(_onResendOTP);
    on<AppStartedEvent>(_onAppStarted);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<ForgotPasswordRequestedEvent>(_onForgotPassword);
    on<ResetPasswordRequestedEvent>(_onResetPassword);
  }

  Future<void> _onSignupRequested(
    SignupRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('📝 Signup requested for email: ${event.email}');
    emit(AuthLoading());
    final result = await signupUser(
      name: event.name,
      email: event.email,
      password: event.password,
      phone: event.phone,
    );

    result.fold(
      (failure) {
        print('❌ Signup failed: ${failure.message}');
        emit(AuthFailure(failure.message));
      },
      (data) {
        print('✅ Signup response: $data');
        if (data['userId'] != null) {
          print('📧 Verification required for user: ${data['userId']}');
          emit(
            EmailVerificationRequired(
              userId: data['userId'],
              email: event.email,
              message: data['message'] ?? "Account created. Enter OTP.",
            ),
          );
        } else {
          print('❌ Signup failed: No user ID returned');
          emit(AuthFailure("Signup failed: No ID returned"));
        }
      },
    );
  }

  Future<void> _onVerifyEmail(
    VerifyEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    print(
      '🔐 Verifying email for user: ${event.userId} with OTP: ${event.otp}',
    );
    emit(AuthLoading());
    final result = await verifyEmail(event.userId, event.otp);

    result.fold(
      (failure) {
        print('❌ Email verification failed: ${failure.message}');
        emit(AuthFailure(failure.message));
      },
      (data) {
        print('✅ Email verification successful!');
        print('   User data: ${data['user']}');
        print('   Token exists: ${data.containsKey('token')}');
        if (data.containsKey('token')) {
          print('   Token: ${data['token'].substring(0, 10)}...');
        }
        emit(EmailVerified(data['user'], token: data['token']));
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 Login requested for email: ${event.email}');
    emit(AuthLoading());
    final result = await loginUser(event.email, event.password);

    result.fold(
      (failure) {
        print('❌ Login failed: ${failure.message}');
        emit(AuthFailure(failure.message));
      },
      (data) {
        print('✅ Login response: $data');
        if (data['requiresVerification'] == true) {
          print('📧 Verification required for user: ${data['userId']}');
          emit(
            EmailVerificationRequired(
              userId: data['userId'],
              email: event.email,
              message: data['message'] ?? "Please verify email first.",
            ),
          );
        } else {
          print('✅ Login successful!');
          print('   User: ${data['user']}');
          print('   Token: ${data['token'].substring(0, 10)}...');
          emit(AuthSuccess(data['user'], token: data['token']));
        }
      },
    );
  }

  Future<void> _onResendOTP(
    ResendOTPEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 Resending OTP to email: ${event.email}');
    final result = await resendOTP(event.email);
    result.fold(
      (failure) {
        print('❌ Resend OTP failed: ${failure.message}');
        emit(AuthFailure(failure.message));
      },
      (data) {
        print('✅ OTP resent successfully');
        emit(OTPResent(data['message'] ?? "New OTP sent"));
      },
    );
  }

  Future<void> _onAppStarted(
    AppStartedEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 AppStartedEvent - checking auth status');
    final result = await checkAuthStatus();
    result.fold(
      (failure) {
        print('❌ No authenticated user: ${failure.message}');
        emit(AuthGuest());
      },
      (user) {
        print('✅ User authenticated: ${user.email}');
        print('   Verified: ${user.isEmailVerified}');
        print('   User ID: ${user.id}');
        print('   Token exists: ${user.token.isNotEmpty}');
        if (user.token.isNotEmpty) {
          print('   Token: ${user.token.substring(0, 10)}...');
        }
        emit(AuthSuccess(user, token: user.token));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🚪 Logout requested');
    emit(AuthGuest());
    print('✅ User logged out');
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔑 Forgot password requested for email: ${event.email}');
    emit(AuthLoading());
    final result = await forgotPassword(event.email);
    result.fold(
      (failure) {
        print('❌ Forgot password failed: ${failure.message}');
        emit(AuthFailure(failure.message));
      },
      (_) {
        print('✅ Reset code sent to email');
        emit(ForgotPasswordSuccess('Reset code sent'));
      },
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔑 Resetting password for email: ${event.email}');
    print('   OTP: ${event.otp}');
    emit(AuthLoading());
    final result = await resetPassword(
      email: event.email,
      otp: event.otp,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) {
        print('❌ Reset password failed: ${failure.message}');
        emit(AuthFailure(failure.message));
      },
      (_) {
        print('✅ Password reset successful');
        emit(ResetPasswordSuccess('Password reset successful'));
      },
    );
  }
}
