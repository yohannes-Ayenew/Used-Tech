// lib/features/auth/domain/usecases/forgot_password.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ForgotPassword {
  final AuthRepository repository;
  ForgotPassword(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> call(String email) =>
      repository.forgotPassword(email);
}
