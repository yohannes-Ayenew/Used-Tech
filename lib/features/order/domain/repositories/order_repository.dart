// lib/features/order/domain/repositories/order_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getBuyingOrders();
  Future<Either<Failure, List<OrderEntity>>> getSellingOrders();
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId);
  Future<Either<Failure, Unit>> acceptOrder(String orderId);
  Future<Either<Failure, Unit>> reportOrderIssue(String orderId, String reason);
  Future<Either<Failure, OrderEntity>> createOrder({required String productId, required String deliveryMethod});
  Future<Either<Failure, OrderEntity>> updateOrderStatus({required String orderId, required OrderStatus status, String? trackingNumber, String? courierName});
  Future<Either<Failure, OrderEntity>> confirmDelivery({required String orderId, required String scannedToken});
  Future<Either<Failure, String>> initPayment(String orderId);
}
