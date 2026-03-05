// lib/features/product/data/models/product_model.dart

import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.sellerId,
    required super.sellerName,
    required super.isSellerVerified,
    super.sellerPhone,
    super.sellerLocation,
    super.sellerProfileImage,
    required super.category,
    required super.brand,
    required super.model,
    required super.condition,
    super.storage,
    super.ram,
    super.processor,
    super.core,
    super.generation,
    required super.title,
    required super.description,
    required super.price,
    required super.images,
    required super.location,
    required super.isEscrow,
    required super.isVerified,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse specs safely
    final specs = json['specs'] ?? {};

    // Parse seller info safely
    final seller = json['sellerId'];
    final sellerName = (seller is Map) ? seller['name'] : 'Unknown Seller';
    final isSellerVerified = (seller is Map)
        ? (seller['role'] == 'VERIFIED_SELLER')
        : false;
    final sellerPhone = (seller is Map) ? seller['phone'] : null;
    final sellerLocation = (seller is Map) ? seller['location'] : null;
    final sellerProfileImage = (seller is Map) ? seller['profileImage'] : null;

    // Helper to map category string to Enum
    ProductCategory parseCategory(String? cat) {
      switch (cat?.toLowerCase()) {
        case 'mobile':
          return ProductCategory.mobile;
        case 'laptop':
          return ProductCategory.laptop;
        case 'tablet':
          return ProductCategory.tablet;
        default:
          return ProductCategory.mobile; // Default
      }
    }

    // Helper to map condition string to Enum
    ProductCondition parseCondition(String? cond) {
      switch (cond?.toLowerCase()) {
        case 'new':
          return ProductCondition.brandNew;
        case 'like new':
          return ProductCondition.likeNew;
        case 'good':
          return ProductCondition.good;
        case 'fair':
          return ProductCondition.fair;
        case 'for parts':
          return ProductCondition.forParts;
        default:
          return ProductCondition.good;
      }
    }

    return ProductModel(
      id: json['_id'] ?? '',
      sellerId: (seller is Map) ? seller['_id'] : (seller ?? ''),
      sellerName: sellerName,
      isSellerVerified: isSellerVerified,
      sellerPhone: sellerPhone,
      sellerLocation: sellerLocation,
      sellerProfileImage: sellerProfileImage,
      category: parseCategory(json['category']),
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      condition: parseCondition(json['condition']),
      storage: specs['storage'],
      ram: specs['ram'],
      processor: specs['processor'],
      core: specs['core'],
      generation: specs['generation'],
      title: "${json['brand']} ${json['model']}", // Virtual Title
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      location: json['location'] ?? 'Addis Ababa',
      isEscrow: true, // Always true for now
      isVerified: isSellerVerified,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
