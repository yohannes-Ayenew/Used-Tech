// lib/features/auth/domain/usecases/verify_email.dart

import 'package:dartz/dartz.dart';
import 'package:used_tech_client/core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyEmail {
  final AuthRepository repository;

  VerifyEmail(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String userId,
    String otp,
  ) async {
    return await repository.verifyEmail(userId, otp);
  }
}
