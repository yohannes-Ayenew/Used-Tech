// lib/features/auth/presentation/bloc/auth_event.dart

import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

// Auth events
class LoginRequestedEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginRequestedEvent({required this.email, required this.password});
}

class SignupRequestedEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  const SignupRequestedEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
}

class VerifyOtpEvent extends AuthEvent {
  final String userId;
  final String otp;
  const VerifyOtpEvent({required this.userId, required this.otp});
}

class AppStartedEvent extends AuthEvent {}

class LogoutRequestedEvent extends AuthEvent {}

// Password reset events
class ForgotPasswordRequestedEvent extends AuthEvent {
  final String email;
  const ForgotPasswordRequestedEvent({required this.email});
}

class ResetPasswordRequestedEvent extends AuthEvent {
  final String userId;
  final String token;
  final String newPassword;
  const ResetPasswordRequestedEvent({
    required this.userId,
    required this.token,
    required this.newPassword,
  });
}

// Profile events
class UpdateProfileRequestedEvent extends AuthEvent {
  final String? name;
  final String? phone;
  const UpdateProfileRequestedEvent({this.name, this.phone});
}

class ChangePasswordRequestedEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  const ChangePasswordRequestedEvent({
    required this.currentPassword,
    required this.newPassword,
  });
}

class RequestVerificationEvent extends AuthEvent {
  final File imageFile;
  const RequestVerificationEvent({required this.imageFile});
}

class GetUserProfileEvent extends AuthEvent {}
