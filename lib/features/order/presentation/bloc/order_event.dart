// lib/features/order/presentation/bloc/order_event.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class GetMyOrdersEvent extends OrderEvent {}

class GetMySalesEvent extends OrderEvent {}

class GetOrderDetailsEvent extends OrderEvent {
  final String orderId;
  const GetOrderDetailsEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class CreateOrderEvent extends OrderEvent {
  final String productId;
  final String deliveryMethod;
  const CreateOrderEvent({
    required this.productId,
    required this.deliveryMethod,
  });

  @override
  List<Object?> get props => [productId, deliveryMethod];
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final OrderStatus status;
  final String? trackingNumber;
  final String? courierName;

  const UpdateOrderStatusEvent({
    required this.orderId,
    required this.status,
    this.trackingNumber,
    this.courierName,
  });

  @override
  List<Object?> get props => [orderId, status, trackingNumber, courierName];
}

class ConfirmDeliveryEvent extends OrderEvent {
  final String orderId;
  final String scannedToken;
  const ConfirmDeliveryEvent({
    required this.orderId,
    required this.scannedToken,
  });

  @override
  List<Object?> get props => [orderId, scannedToken];
}

class AcceptOrderEvent extends OrderEvent {
  final String orderId;
  const AcceptOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class ReportOrderIssueEvent extends OrderEvent {
  final String orderId;
  final String reason;
  const ReportOrderIssueEvent({required this.orderId, required this.reason});

  @override
  List<Object?> get props => [orderId, reason];
}

class InitPaymentEvent extends OrderEvent {
  final String orderId;
  const InitPaymentEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
