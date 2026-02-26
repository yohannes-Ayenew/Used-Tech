import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:used_tech_client/features/auth/domain/usecases/change_password.dart';
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
  // Use Cases
  final LoginUser loginUser;
  final SignupUser signupUser;
  final VerifyEmail verifyEmail;
  final ResendOTP resendOTP;
  final CheckAuthStatus checkAuthStatus;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final ChangePassword changePassword;

  // Repository (Direct access for Google Sign In to save creating a specific UseCase file)
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUser,
    required this.signupUser,
    required this.verifyEmail,
    required this.resendOTP,
    required this.checkAuthStatus,
    required this.forgotPassword,
    required this.resetPassword,
    required this.changePassword,
    required this.authRepository, // Injected dependency
  }) : super(AuthInitial()) {
    // Register Event Handlers
    on<SignupRequestedEvent>(_onSignupRequested);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<LoginRequestedEvent>(_onLoginRequested);
    on<GoogleSignInRequestedEvent>(_onGoogleSignIn); // New Google Handler
    on<ResendOTPEvent>(_onResendOTP);
    on<AppStartedEvent>(_onAppStarted);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<ForgotPasswordRequestedEvent>(_onForgotPassword);
    on<ResetPasswordRequestedEvent>(_onResetPassword);
    on<ChangePasswordRequestedEvent>(_onChangePasswordRequested);
    on<RequestVerificationEvent>(_onRequestVerification);
  }

  bool? get mounted => null;

  // --- Google Sign In Handler ---
  Future<void> _onGoogleSignIn(
    GoogleSignInRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🚀 Google Sign In requested');
    emit(AuthLoading());

    // Call the repository directly
    final result = await authRepository.signInWithGoogle();

    result.fold(
      (failure) {
        print('❌ Google Sign In failed: ${failure.message}');
        emit(AuthFailure(failure.message));
      },
      (data) {
        print('✅ Google Sign In successful!');
        // user object is in data['user'], token is in data['token']
        emit(AuthSuccess(data['user'], token: data['token']));
      },
    );
  }

  // --- Signup Handler ---
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

  // --- Verify Email Handler ---
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

        // IMMEDIATE LOGIN SUCCESS
        emit(AuthSuccess(data['user'], token: data['token']));
      },
    );
  }

  // --- Login Handler ---
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
          emit(AuthSuccess(data['user'], token: data['token']));
        }
      },
    );
  }

  // --- Resend OTP Handler ---
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

  // --- App Started (Check Auth) Handler ---
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
        emit(AuthSuccess(user, token: user.token));
      },
    );
  }

  // --- Logout Handler ---
  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🚪 Logout requested');
    // In a real app, you might want to call authRepository.logout() here to clear storage
    emit(AuthGuest());
    print('✅ User logged out');
  }

  // --- Forgot Password Handler ---
  Future<void> _onForgotPassword(
    ForgotPasswordRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await forgotPassword(event.email);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (data) => emit(ForgotPasswordSuccess(data['message'])),
    );
  }

  // --- Reset Password Handler ---
  Future<void> _onResetPassword(
    ResetPasswordRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resetPassword(
      email: event.email,
      otp: event.otp,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (data) => emit(ResetPasswordSuccess(data['message'])),
    );
  }

  // --- Change Password Handler ---
  Future<void> _onChangePasswordRequested(
    ChangePasswordRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 Change password requested');
    emit(AuthLoading());

    // Add safety timeout
    Future.delayed(const Duration(seconds: 20), () {
      // Using a simple check to prevent emitting if state changed
      // Note: In strict Bloc, prefer cancelling operations
    });

    try {
      final result = await changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      print('📥 Change password result: $result');

      result.fold(
        (failure) {
          print('❌ Change password failed: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (_) {
          print('✅ Change password successful');
          emit(PasswordChangeSuccess('Password changed successfully'));
        },
      );
    } catch (e) {
      print('❌ Change password exception: $e');
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRequestVerification(
    RequestVerificationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.requestVerification(
      frontImage: event.frontImage,
      backImage: event.backImage,
      faceImage: event.faceImage,
    );

    result.fold(
      (failure) {
        emit(AuthFailure(failure.message));
        // Important: Reload current user state so the UI doesn't get stuck in loading
        add(AppStartedEvent());
      },
      (_) async {
        // Success!
        emit(const VerificationRequestSuccess(
            "Verification submitted successfully"));

        // Refresh user data to show "Pending" status in UI immediately
        add(AppStartedEvent());
      },
    );
  }
}
