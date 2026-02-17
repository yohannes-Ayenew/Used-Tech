// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:used_tech_client/core/error/failures.dart';
import '../entities/user_entity.dart';
import 'dart:io';

abstract class AuthRepository {
  // Auth methods
  Future<Either<Failure, Map<String, dynamic>>> login(
    String email,
    String password,
  );

  Future<Either<Failure, Map<String, dynamic>>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<Either<Failure, Map<String, dynamic>>> verifyOtp(
    String userId,
    String otp,
  );

  Future<Either<Failure, UserEntity>> checkAuthStatus();

  // Password reset
  Future<Either<Failure, void>> forgotPassword(String email);

  Future<Either<Failure, void>> resetPassword({
    required String userId,
    required String token,
    required String newPassword,
  });

  // Profile methods
  Future<Either<Failure, UserEntity>> getUserProfile();

  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? phone,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> requestVerification({required File imageFile});

  Future<Either<Failure, void>> logout();
}
