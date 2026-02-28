import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
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
  });

  Future<Either<Failure, List<ProductEntity>>> getProducts();
}
