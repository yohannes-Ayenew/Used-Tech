// lib/features/order/domain/entities/order_entity.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  escrowHeld,
  shipped,
  delivered,
  completed,
  disputed,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.escrowHeld:
        return 'Escrow Held';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.disputed:
        return 'Disputed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.escrowHeld:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.teal;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.disputed:
        return Colors.red;
      case OrderStatus.cancelled:
        return Colors.grey;
    }
  }
}

class OrderEntity extends Equatable {
  final String id;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String productId;
  final String productTitle;
  final String productImage;
  final double amount;
  final OrderStatus status;
  final String? deliveryToken;
  final DateTime? deliveredAt;
  final DateTime? autoConfirmAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.amount,
    required this.status,
    this.deliveryToken,
    this.deliveredAt,
    this.autoConfirmAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedAmount => amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );

  // Helper getters
  bool get isPending => status == OrderStatus.pending;
  bool get isEscrowHeld => status == OrderStatus.escrowHeld;
  bool get isShipped => status == OrderStatus.shipped;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isDisputed => status == OrderStatus.disputed;
  bool get isCancelled => status == OrderStatus.cancelled;

  // Check if user can cancel
  bool get canCancel => isPending || isEscrowHeld;

  // Check if seller can mark as shipped
  bool get canMarkShipped => isEscrowHeld;

  // Check if buyer can confirm delivery
  bool get canConfirmDelivery => isDelivered && !isCompleted;

  @override
  List<Object?> get props => [
    id,
    buyerId,
    sellerId,
    productId,
    amount,
    status,
    createdAt,
  ];

  OrderEntity copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? sellerId,
    String? sellerName,
    String? productId,
    String? productTitle,
    String? productImage,
    double? amount,
    OrderStatus? status,
    String? deliveryToken,
    DateTime? deliveredAt,
    DateTime? autoConfirmAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productImage: productImage ?? this.productImage,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      deliveryToken: deliveryToken ?? this.deliveryToken,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      autoConfirmAt: autoConfirmAt ?? this.autoConfirmAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
