// lib/features/auth/domain/usecases/resend_otp.dart

import 'package:dartz/dartz.dart';
import 'package:used_tech_client/core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResendOTP {
  final AuthRepository repository;

  ResendOTP(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String email) async {
    return await repository.resendOTP(email);
  }
}
