// lib/features/auth/domain/usecases/check_auth_status.dart

import 'package:dartz/dartz.dart';
import 'package:used_tech_client/core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.checkAuthStatus();
  }
}
