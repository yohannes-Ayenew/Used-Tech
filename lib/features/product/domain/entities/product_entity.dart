// lib/features/product/domain/entities/product_entity.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ProductCondition {
  brandNew,
  likeNew,
  good,
  fair,
  forParts;

  String get displayName {
    switch (this) {
      case ProductCondition.brandNew:
        return 'Brand New';
      case ProductCondition.likeNew:
        return 'Like New';
      case ProductCondition.good:
        return 'Good';
      case ProductCondition.fair:
        return 'Fair';
      case ProductCondition.forParts:
        return 'For Parts';
    }
  }

  Color get color {
    switch (this) {
      case ProductCondition.brandNew:
        return Colors.green;
      case ProductCondition.likeNew:
        return Colors.teal;
      case ProductCondition.good:
        return Colors.blue;
      case ProductCondition.fair:
        return Colors.orange;
      case ProductCondition.forParts:
        return Colors.red;
    }
  }
}

enum ProductCategory {
  mobile,
  laptop,
  tablet;

  String get displayName {
    switch (this) {
      case ProductCategory.mobile:
        return 'Mobile Phone';
      case ProductCategory.laptop:
        return 'Laptop / Computer';
      case ProductCategory.tablet:
        return 'Tablet';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductCategory.mobile:
        return Icons.phone_android;
      case ProductCategory.laptop:
        return Icons.laptop;
      case ProductCategory.tablet:
        return Icons.tablet_android;
    }
  }
}

class ProductEntity extends Equatable {
  final String id;
  final String sellerId;
  final String sellerName;
  final bool isSellerVerified;
  final String? sellerPhone;
  final String? sellerLocation;
  final ProductCategory category;
  final String brand;
  final String model;
  final ProductCondition condition;
  final String? storage;
  final String? ram;
  final String? processor;
  final String? core;
  final String? generation;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String location;
  final bool isEscrow;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.isSellerVerified,
    this.sellerPhone,
    this.sellerLocation,
    required this.category,
    required this.brand,
    required this.model,
    required this.condition,
    this.storage,
    this.ram,
    this.processor,
    this.core,
    this.generation,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.location,
    required this.isEscrow,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  String get formattedPrice => price
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );

  String get coverImage => images.isNotEmpty ? images.first : '';

  bool get hasStorage => storage != null && storage!.isNotEmpty;
  bool get hasRam => ram != null && ram!.isNotEmpty;
  bool get hasProcessor => processor != null && processor!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    sellerId,
    sellerName,
    isSellerVerified,
    sellerPhone,
    sellerLocation,
    category,
    brand,
    model,
    condition,
    storage,
    ram,
    processor,
    core,
    generation,
    price,
    createdAt,
  ];
}
