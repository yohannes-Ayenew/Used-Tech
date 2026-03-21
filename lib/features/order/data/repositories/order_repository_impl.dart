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
      // If not in buying, check selling (simplified for mock)
      return Right(_mockOrders.first); 
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> reportOrderIssue(String orderId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const Right(unit);
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder({required String productId, required String deliveryMethod}) async {
    await Future.delayed(const Duration(seconds: 1));
    return Right(_mockOrders.first);
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus({required String orderId, required OrderStatus status}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final order = _mockOrders.first.copyWith(status: status);
    return Right(order);
  }

  @override
  Future<Either<Failure, OrderEntity>> confirmDelivery({required String orderId, required String scannedToken}) async {
    await Future.delayed(const Duration(seconds: 1));
    final order = _mockOrders.first.copyWith(status: OrderStatus.completed);
    return Right(order);
  }
}
