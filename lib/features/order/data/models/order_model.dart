// lib/features/order/data/models/order_model.dart

import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.buyerId,
    required super.buyerName,
    required super.sellerId,
    required super.sellerName,
    required super.productId,
    required super.productTitle,
    required super.productImage,
    required super.amount,
    required super.status,
    super.deliveryToken,
    super.deliveredAt,
    super.autoConfirmAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      buyerId: json['buyerId'] is Map ? json['buyerId']['_id'] : json['buyerId'] ?? '',
      buyerName: json['buyerId'] is Map ? (json['buyerId']['name'] ?? 'Unknown Buyer') : 'Unknown Buyer',
      sellerId: json['sellerId'] is Map ? json['sellerId']['_id'] : json['sellerId'] ?? '',
      sellerName: json['sellerId'] is Map ? (json['sellerId']['name'] ?? 'Unknown Seller') : 'Unknown Seller',
      productId: json['productId'] is Map ? json['productId']['_id'] : json['productId'] ?? '',
      productTitle: json['productId'] is Map 
          ? (json['productId']['title'] ?? 
             ((json['productId']['brand'] != null && json['productId']['model'] != null)
                 ? '${json['productId']['brand']} ${json['productId']['model']}'
                 : 'Unknown Product'))
          : 'Unknown Product',
      productImage: (json['productId'] is Map && json['productId']['images'] is List && (json['productId']['images'] as List).isNotEmpty)
          ? json['productId']['images'].first
          : '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(json['status']),
      deliveryToken: json['deliveryToken'],
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      autoConfirmAt: json['autoConfirmAt'] != null ? DateTime.parse(json['autoConfirmAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static OrderStatus _parseStatus(String? status) {
    if (status == null) return OrderStatus.pending;
    
    // Normalize string: lowercase, remove spaces, underscores, and hyphens
    final normalized = status.toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll('-', '');
        
    switch (normalized) {
      case 'pending':
        return OrderStatus.pending;
      case 'escrowheld':
      case 'escrow':
        return OrderStatus.escrowHeld;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
      case 'complete':
        return OrderStatus.completed;
      case 'disputed':
      case 'dispute':
        return OrderStatus.disputed;
      case 'cancelled':
      case 'cancel':
        return OrderStatus.cancelled;
      default:
        print('⚠️ Unknown order status from backend: $status');
        return OrderStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'amount': amount,
      // Add other fields if needed for API requests
    };
  }
}
