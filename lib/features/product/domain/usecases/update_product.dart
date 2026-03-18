// lib/features/product/domain/usecases/update_product.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<Either<Failure, void>> call({
    required String productId,
    required Map<String, dynamic> productData,
  }) async {
    return await repository.updateProduct(
      productId,
      productData,
    );
  }
}
