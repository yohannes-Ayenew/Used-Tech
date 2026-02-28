import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_entity.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProductEntity>> createProduct({
    required String category,
    required String brand,
    required String model,
    required String condition,
    required String title,
    required String description,
    required double price,
    required String location,
    String? storage,
    String? ram,
    String? processor,
    required List<XFile> images,
  }) async {
    try {
      final product = await remoteDataSource.createProduct(
        category: category,
        brand: brand,
        model: model,
        condition: condition,
        title: title,
        description: description,
        price: price,
        location: location,
        storage: storage,
        ram: ram,
        processor: processor,
        images: images,
      );
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
