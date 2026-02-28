import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(CreateProductParams params) async {
    return await repository.createProduct(
      category: params.category,
      brand: params.brand,
      model: params.model,
      condition: params.condition,
      title: params.title,
      description: params.description,
      price: params.price,
      location: params.location,
      storage: params.storage,
      ram: params.ram,
      processor: params.processor,
      images: params.images,
    );
  }
}

class CreateProductParams extends Equatable {
  final String category;
  final String brand;
  final String model;
  final String condition;
  final String title;
  final String description;
  final double price;
  final String location;
  final String? storage;
  final String? ram;
  final String? processor;
  final List<XFile> images;

  const CreateProductParams({
    required this.category,
    required this.brand,
    required this.model,
    required this.condition,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    this.storage,
    this.ram,
    this.processor,
    required this.images,
  });

  @override
  List<Object?> get props => [
        category,
        brand,
        model,
        condition,
        title,
        description,
        price,
        location,
        storage,
        ram,
        processor,
        images,
      ];
}
