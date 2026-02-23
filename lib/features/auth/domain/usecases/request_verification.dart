// lib/features/auth/domain/usecases/request_verification.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:used_tech_client/core/error/failures.dart';
import '../repositories/auth_repository.dart';

class RequestVerification {
  final AuthRepository repository;

  RequestVerification(this.repository);

  Future<Either<Failure, void>> call({required File imageFile}) async {
    return await repository.requestVerification(imageFile: imageFile);
  }
}
