import 'package:dartz/dartz.dart';
import 'package:used_tech_client/core/error/failures.dart';
import 'package:used_tech_client/features/auth/data/datasources/auth_local_data_source.dart';
import '../datasources/order_remote_data_source.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final AuthLocalDataSource authLocalDataSource;
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({
    required this.authLocalDataSource,
    required this.remoteDataSource,
  });

  Future<String> _getCurrentUserId() async {
    final user = await authLocalDataSource.getCachedUser();
    return user?.id ?? '';
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getBuyingOrders() async {
    try {
      final userId = await _getCurrentUserId();
      final allOrders = await remoteDataSource.getMyOrders();
      final buyingOrders = allOrders.where((o) => o.buyerId == userId).toList();
      return Right(buyingOrders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getSellingOrders() async {
    try {
      final userId = await _getCurrentUserId();
      final allOrders = await remoteDataSource.getMyOrders();
      final sellingOrders = allOrders.where((o) => o.sellerId == userId).toList();
      return Right(sellingOrders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId) async {
    try {
      final allOrders = await remoteDataSource.getMyOrders();
      final order = allOrders.firstWhere((o) => o.id == orderId);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptOrder(String orderId) async {
    try {
      await remoteDataSource.completeOrder(orderId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> reportOrderIssue(String orderId, String reason) async {
    // Currently no backend support for disputing/reporting issue. Just simulating success.
    await Future.delayed(const Duration(milliseconds: 800));
    return const Right(unit);
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder({required String productId, required String deliveryMethod}) async {
    try {
      final order = await remoteDataSource.createOrder(productId: productId, deliveryMethod: deliveryMethod);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus({required String orderId, required OrderStatus status}) async {
    try {
      if (status == OrderStatus.shipped) {
        final order = await remoteDataSource.markShipped(orderId);
        return Right(order);
      } else {
        return Left(ServerFailure("Unsupported status update from repository"));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> confirmDelivery({required String orderId, required String scannedToken}) async {
    try {
      final order = await remoteDataSource.confirmDelivery(orderId: orderId, scannedToken: scannedToken);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> initPayment(String orderId) async {
    try {
      final url = await remoteDataSource.initPayment(orderId);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
