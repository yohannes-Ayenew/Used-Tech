// lib/features/wallet/domain/entities/transaction_entity.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TransactionType {
  deposit,
  withdrawal,
  purchaseHold,
  saleEarning,
  refund;

  String get displayName {
    switch (this) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.purchaseHold:
        return 'Purchase Hold';
      case TransactionType.saleEarning:
        return 'Sale Earning';
      case TransactionType.refund:
        return 'Refund';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.deposit:
        return Icons.add_circle;
      case TransactionType.withdrawal:
        return Icons.remove_circle;
      case TransactionType.purchaseHold:
        return Icons.lock;
      case TransactionType.saleEarning:
        return Icons.attach_money;
      case TransactionType.refund:
        return Icons.replay;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.deposit:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.red;
      case TransactionType.purchaseHold:
        return Colors.blue;
      case TransactionType.saleEarning:
        return Colors.green;
      case TransactionType.refund:
        return Colors.orange;
    }
  }
}

enum TransactionStatus {
  pending,
  success,
  failed;

  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.success:
        return 'Success';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.success:
        return Colors.green;
      case TransactionStatus.failed:
        return Colors.red;
    }
  }
}

class TransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final double? balance;
  final String? orderId;
  final String? orderTitle;
  final String description;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    this.balance,
    this.orderId,
    this.orderTitle,
    required this.description,
    required this.createdAt,
  });

  String get formattedAmount {
    final sign = type == TransactionType.withdrawal ? '-' : '+';
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$sign $formatted ETB';
  }

  Color get amountColor {
    switch (type) {
      case TransactionType.deposit:
      case TransactionType.saleEarning:
      case TransactionType.refund:
        return Colors.green;
      case TransactionType.withdrawal:
      case TransactionType.purchaseHold:
        return Colors.red;
    }
  }

  @override
  List<Object?> get props => [id, type, status, amount, description, createdAt];
}
