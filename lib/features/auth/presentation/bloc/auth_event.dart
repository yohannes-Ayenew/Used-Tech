// lib/features/auth/presentation/bloc/auth_event.dart

import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

// Login events
class LoginRequestedEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginRequestedEvent({required this.email, required this.password});
}

// Signup events
class SignupRequestedEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? phone;

  const SignupRequestedEvent({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });

  @override
  List<Object> get props => [name, email, password, phone ?? ''];
}

class GoogleSignInRequestedEvent extends AuthEvent {}

// Email verification events
class VerifyEmailEvent extends AuthEvent {
  final String userId;
  final String otp;
  const VerifyEmailEvent({required this.userId, required this.otp});
}

class ResendOTPEvent extends AuthEvent {
  final String email;
  const ResendOTPEvent({required this.email});
}

// App startup
class AppStartedEvent extends AuthEvent {}

// Logout
class LogoutRequestedEvent extends AuthEvent {}

// Password reset events
class ForgotPasswordRequestedEvent extends AuthEvent {
  final String email;
  const ForgotPasswordRequestedEvent({required this.email});
}

class ResetPasswordRequestedEvent extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;

  const ResetPasswordRequestedEvent({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, otp, newPassword];
}

// Profile events
class UpdateProfileRequestedEvent extends AuthEvent {
  final String? name;
  final String? phone;
  const UpdateProfileRequestedEvent({this.name, this.phone});

  @override
  List<Object> get props => [name ?? '', phone ?? ''];
}

class ChangePasswordRequestedEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  const ChangePasswordRequestedEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class RequestVerificationEvent extends AuthEvent {
  final XFile frontImage;
  final XFile backImage;
  final XFile faceImage;

  const RequestVerificationEvent({
    required this.frontImage,
    required this.backImage,
    required this.faceImage,
  });

  @override
  List<Object> get props => [frontImage, backImage, faceImage];
}

class GetUserProfileEvent extends AuthEvent {}
