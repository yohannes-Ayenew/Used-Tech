// lib/features/product/domain/usecases/create_product.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<Either<Failure, void>> call({
    required Map<String, dynamic> productData,
    required List<File> images,
  }) async {
    return await repository.createProduct(
      productData: productData,
      images: images,
    );
  }
}
