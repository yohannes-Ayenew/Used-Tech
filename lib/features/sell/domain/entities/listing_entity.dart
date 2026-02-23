// lib/features/sell/domain/entities/listing_entity.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:used_tech_client/features/product/domain/entities/product_entity.dart';

enum ListingStatus {
  active,
  sold,
  hidden;

  String get displayName {
    switch (this) {
      case ListingStatus.active:
        return 'Active';
      case ListingStatus.sold:
        return 'Sold';
      case ListingStatus.hidden:
        return 'Hidden';
    }
  }

  Color get color {
    switch (this) {
      case ListingStatus.active:
        return Colors.green;
      case ListingStatus.sold:
        return Colors.grey;
      case ListingStatus.hidden:
        return Colors.orange;
    }
  }
}

class ListingEntity extends Equatable {
  final String id;
  final ProductCategory category;
  final String brand;
  final String model;
  final ProductCondition condition;
  final String? storage;
  final String? ram;
  final String? processor;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final ListingStatus status;
  final int views;
  final int saves;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ListingEntity({
    required this.id,
    required this.category,
    required this.brand,
    required this.model,
    required this.condition,
    this.storage,
    this.ram,
    this.processor,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.status,
    required this.views,
    required this.saves,
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

  bool get isActive => status == ListingStatus.active;
  bool get isSold => status == ListingStatus.sold;
  bool get isHidden => status == ListingStatus.hidden;

  bool get hasStorage => storage != null && storage!.isNotEmpty;
  bool get hasRam => ram != null && ram!.isNotEmpty;
  bool get hasProcessor => processor != null && processor!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    category,
    brand,
    model,
    condition,
    price,
    status,
    createdAt,
  ];
}
