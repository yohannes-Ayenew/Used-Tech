// lib/features/order/presentation/bloc/order_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;
  const OrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

class SalesLoaded extends OrderState {
  final List<OrderEntity> sales;
  const SalesLoaded(this.sales);

  @override
  List<Object> get props => [sales];
}

class OrderDetailsLoaded extends OrderState {
  final OrderEntity order;
  const OrderDetailsLoaded(this.order);

  @override
  List<Object> get props => [order];
}

class OrderCreated extends OrderState {
  final OrderEntity order;
  const OrderCreated(this.order);

  @override
  List<Object> get props => [order];
}

class OrderStatusUpdated extends OrderState {
  final OrderEntity order;
  const OrderStatusUpdated(this.order);

  @override
  List<Object> get props => [order];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);

  @override
  List<Object> get props => [message];
}
