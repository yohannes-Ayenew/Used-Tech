// lib/features/auth/domain/usecases/reset_password.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repository;
  ResetPassword(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> call({
    required String email,
    required String otp,
    required String newPassword,
  }) => repository.resetPassword(
    email: email,
    otp: otp,
    newPassword: newPassword,
  );
}
