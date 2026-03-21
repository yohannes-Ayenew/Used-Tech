// lib/features/order/data/repositories/order_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:used_tech_client/core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  // Mock data for demonstration
  final List<OrderEntity> _mockOrders = [
    OrderEntity(
      id: 'ORD-12345',
      buyerId: 'buyer1',
      buyerName: 'Yohannes',
      sellerId: 'seller1',
      sellerName: 'Apple Store',
      productId: 'p1',
      productTitle: 'iPhone 13 Pro',
      productImage: 'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?q=80&w=400&auto=format&fit=crop',
      amount: 50000,
      status: OrderStatus.delivered,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 19, minutes: 53)),
    ),
    OrderEntity(
      id: 'ORD-12346',
      buyerId: 'buyer1',
      buyerName: 'Yohannes',
      sellerId: 'seller2',
      sellerName: 'Mac Shop',
      productId: 'p2',
      productTitle: 'MacBook Air M1',
      productImage: 'https://images.unsplash.com/photo-1611186871348-b1ec696e52c9?q=80&w=400&auto=format&fit=crop',
      amount: 85000,
      status: OrderStatus.shipped,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
     OrderEntity(
      id: 'ORD-12347',
      buyerId: 'buyer1',
      buyerName: 'Yohannes',
      sellerId: 'seller3',
      sellerName: 'Samsung Official',
      productId: 'p3',
      productTitle: 'Samsung Galaxy S21',
      productImage: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?q=80&w=400&auto=format&fit=crop',
      amount: 32000,
      status: OrderStatus.escrowHeld,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  Future<Either<Failure, List<OrderEntity>>> getBuyingOrders() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Right(_mockOrders);
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getSellingOrders() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulate selling orders for the same user (if they are a seller too)
     return Right([
       OrderEntity(
        id: 'ORD-22345',
        buyerId: 'user_X',
        buyerName: 'Abebe Kebe',
        sellerId: 'buyer1',
        sellerName: 'Yohannes',
        productId: 'p12',
        productTitle: 'iPhone 12',
        productImage: 'https://images.unsplash.com/photo-1603791440384-56cd371ee9a7?q=80&w=400&auto=format&fit=crop',
        amount: 38000,
        status: OrderStatus.shipped,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
       OrderEntity(
        id: 'ORD-22346',
        buyerId: 'user_Y',
        buyerName: 'Mulu Tesfaye',
        sellerId: 'buyer1',
        sellerName: 'Yohannes',
        productId: 'p13',
        productTitle: 'HP Pavilion',
        productImage: 'https://images.unsplash.com/photo-1544006659-f0b21884ce1d?q=80&w=400&auto=format&fit=crop',
        amount: 42000,
        status: OrderStatus.escrowHeld,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
     ]);
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final order = _mockOrders.firstWhere((o) => o.id == orderId);
      return Right(order);
    } catch (_) {
      // For mock purposes, if not found, return the first one but with requested ID
      if (_mockOrders.isNotEmpty) {
        return Right(_mockOrders.first.copyWith(id: orderId));
      }
      return Left(ServerFailure("Order not found"));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      final index = _mockOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _mockOrders[index] = _mockOrders[index].copyWith(
          status: OrderStatus.completed,
          updatedAt: DateTime.now(),
        );
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> reportOrderIssue(String orderId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      final index = _mockOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _mockOrders[index] = _mockOrders[index].copyWith(
          status: OrderStatus.disputed,
          updatedAt: DateTime.now(),
        );
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder({required String productId, required String deliveryMethod}) async {
    await Future.delayed(const Duration(seconds: 1));
    final newOrder = OrderEntity(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      buyerId: 'buyer1',
      buyerName: 'Yohannes',
      sellerId: 'seller1',
      sellerName: 'Apple Store',
      productId: productId,
      productTitle: 'Created Order',
      productImage: '',
      amount: 45000,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockOrders.add(newOrder);
    return Right(newOrder);
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus({required String orderId, required OrderStatus status}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _mockOrders[index] = _mockOrders[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      return Right(_mockOrders[index]);
    }
    return Left(ServerFailure("Order not found"));
  }

  @override
  Future<Either<Failure, OrderEntity>> confirmDelivery({required String orderId, required String scannedToken}) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final now = DateTime.now();
      _mockOrders[index] = _mockOrders[index].copyWith(
        status: OrderStatus.delivered,
        deliveredAt: now,
        autoConfirmAt: now.add(const Duration(hours: 24)),
        updatedAt: now,
      );
      return Right(_mockOrders[index]);
    }
    return Left(ServerFailure("Order not found"));
  }
}
