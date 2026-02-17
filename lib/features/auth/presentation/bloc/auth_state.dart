// lib/features/auth/presentation/bloc/auth_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;
  final String token;
  const AuthSuccess(this.user, {required this.token});
  @override
  List<Object> get props => [user, token];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object> get props => [message];
}

class AuthGuest extends AuthState {}

// OTP states
class OtpRequiredState extends AuthState {
  final String userId;
  final String message;
  const OtpRequiredState({required this.userId, required this.message});
  @override
  List<Object> get props => [userId, message];
}

class OtpVerifiedState extends AuthState {
  final UserEntity user;
  final String token;
  const OtpVerifiedState(this.user, {required this.token});
  @override
  List<Object> get props => [user, token];
}

// Password reset states
class ForgotPasswordSuccess extends AuthState {
  final String message;
  const ForgotPasswordSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class ResetPasswordSuccess extends AuthState {
  final String message;
  const ResetPasswordSuccess(this.message);
  @override
  List<Object> get props => [message];
}

// Profile update states
class ProfileUpdateSuccess extends AuthState {
  final UserEntity user;
  const ProfileUpdateSuccess(this.user);
  @override
  List<Object> get props => [user];
}

class PasswordChangeSuccess extends AuthState {
  final String message;
  const PasswordChangeSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class VerificationRequestSuccess extends AuthState {
  final String message;
  const VerificationRequestSuccess(this.message);
  @override
  List<Object> get props => [message];
}
