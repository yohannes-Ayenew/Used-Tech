// lib/features/auth/domain/usecases/update_profile.dart

import 'package:dartz/dartz.dart';
import 'package:used_tech_client/core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<Either<Failure, UserEntity>> call({
    String? name,
    String? phone,
  }) async {
    return await repository.updateProfile(name: name, phone: phone);
  }
}
