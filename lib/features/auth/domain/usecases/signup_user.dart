// lib/features/auth/domain/usecases/signup_user.dart

import 'package:dartz/dartz.dart';
import 'package:used_tech_client/core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SignupUser {
  final AuthRepository repository;

  SignupUser(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    return await repository.signup(
      name: name,
      email: email,
      password: password,
    );
  }
}
