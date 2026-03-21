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
      buyerId: json['buyerId']?['_id'] ?? json['buyerId'] ?? '',
      buyerName: json['buyerId']?['name'] ?? 'Unknown Buyer',
      sellerId: json['sellerId']?['_id'] ?? json['sellerId'] ?? '',
      sellerName: json['sellerId']?['name'] ?? 'Unknown Seller',
      productId: json['productId']?['_id'] ?? json['productId'] ?? '',
      productTitle: json['productId']?['title'] ?? 'Unknown Product',
      productImage: (json['productId']?['images'] as List?)?.first ?? '',
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
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'escrow_held':
        return OrderStatus.escrowHeld;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
        return OrderStatus.completed;
      case 'disputed':
        return OrderStatus.disputed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
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
