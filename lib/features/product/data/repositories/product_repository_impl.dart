// lib/features/product/data/repositories/product_repository_impl.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  
  // 🚀 Simple In-Memory Cache
  static final Map<String, List<ProductEntity>> _cache = {};

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createProduct({
    required Map<String, dynamic> productData,
    required List<File> images,
  }) async {
    try {
      await remoteDataSource.createProduct(
        productData: productData,
        images: images,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? searchQuery,
    String? location,
    String? sellerId,
  }) async {
    final cacheKey = "${category ?? 'all'}_${searchQuery ?? 'none'}_${location ?? 'any'}_${sellerId ?? 'any'}";

    // 💡 Optional: Return cached data immediately if available (Fast UI)
    // For now, we fetch fresh but we can evolve this to "Cache then Refresh"
    
    try {
      final products = await remoteDataSource.getProducts(
        category: category,
        search: searchQuery,
        location: location,
        sellerId: sellerId,
      );
      
      _cache[cacheKey] = products; // Update cache
      return Right(products);
    } on ServerException catch (e) {
      // If network fails, try to return from cache instead of erroring
      if (_cache.containsKey(cacheKey)) {
        return Right(_cache[cacheKey]!);
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      if (_cache.containsKey(cacheKey)) {
        return Right(_cache[cacheKey]!);
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
