import 'package:dartz/dartz.dart';
import 'package:used_tech_client/core/error/failures.dart';
import '../entities/user_entity.dart';
import 'dart:io';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> login(String email, String password);

  Future<Either<Failure, Map<String, dynamic>>> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<Either<Failure, Map<String, dynamic>>> verifyEmail(String userId, String otp);

  Future<Either<Failure, Map<String, dynamic>>> resendOTP(String email);

  Future<Either<Failure, UserEntity>> checkAuthStatus();

  Future<Either<Failure, void>> forgotPassword(String email);

   Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<Either<Failure, UserEntity>> getUserProfile();

  Future<Either<Failure, UserEntity>> updateProfile({String? name, String? phone});

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> requestVerification({required File imageFile});

  Future<Either<Failure, void>> logout();
}