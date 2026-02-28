import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.sellerId,
    required super.sellerName,
    required super.isSellerVerified,
    required super.category,
    required super.brand,
    required super.model,
    required super.condition,
    super.storage,
    super.ram,
    super.processor,
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
    return ProductModel(
      id: json['_id'],
      sellerId: json['sellerId'], // Ensure backend returns string or object
      sellerName: json['sellerName'] ?? 'Unknown',
      isSellerVerified: json['isSellerVerified'] ?? false,
      category: _mapCategory(json['category']),
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      condition: _mapCondition(json['condition']),
      storage: json['storage'],
      ram: json['ram'],
      processor: json['processor'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      location: json['location'] ?? '',
      isEscrow: json['isEscrow'] ?? false,
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static ProductCategory _mapCategory(String? categoryRaw) {
    if (categoryRaw == null) return ProductCategory.mobile;
    switch (categoryRaw.toLowerCase()) {
      case 'laptop':
        return ProductCategory.laptop;
      case 'tablet':
        return ProductCategory.tablet;
      case 'mobile':
      default:
        return ProductCategory.mobile;
    }
  }

  static ProductCondition _mapCondition(String? conditionRaw) {
    if (conditionRaw == null) return ProductCondition.good;
    switch (conditionRaw.toLowerCase()) {
      case 'brand new':
      case 'brandnew':
        return ProductCondition.brandNew;
      case 'like new':
      case 'likenew':
        return ProductCondition.likeNew;
      case 'good':
        return ProductCondition.good;
      case 'fair':
        return ProductCondition.fair;
      case 'for parts':
      case 'forparts':
        return ProductCondition.forParts;
      default:
        return ProductCondition.good;
    }
  }
}
