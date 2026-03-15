// lib/features/product/domain/repositories/product_repository.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, void>> createProduct({
    required Map<String, dynamic> productData,
    required List<File> images,
  });

  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? searchQuery,
    String? location,
    String? sellerId,
    String? status,
    int? limit,
    String? sort,
  });

  Future<Either<Failure, ProductEntity>> getProductById(String id);
}
