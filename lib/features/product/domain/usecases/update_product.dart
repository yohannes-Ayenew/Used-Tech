// lib/features/product/domain/usecases/update_product.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<Either<Failure, void>> call(String id, Map<String, dynamic> productData, {List<File>? images}) async {
    return await repository.updateProduct(id, productData, images: images);
  }
}
