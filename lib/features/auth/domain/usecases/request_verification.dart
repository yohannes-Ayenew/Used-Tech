// lib/features/auth/domain/usecases/request_verification.dart

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart'; // Add this import
import 'package:used_tech_client/core/error/failures.dart';
import '../repositories/auth_repository.dart';

class RequestVerification {
  final AuthRepository repository;

  RequestVerification(this.repository);

  // Update signature to accept 3 images (XFile)
  Future<Either<Failure, void>> call({
    required XFile frontImage,
    required XFile backImage,
    required XFile faceImage,
  }) async {
    return await repository.requestVerification(
      frontImage: frontImage,
      backImage: backImage,
      faceImage: faceImage,
    );
  }
}
