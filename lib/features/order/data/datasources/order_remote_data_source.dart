import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../injection_container.dart' as di;
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getMyOrders();
  Future<OrderModel> createOrder({required String productId, required String deliveryMethod});
  Future<OrderModel> markShipped(String orderId);
  Future<OrderModel> confirmDelivery({required String orderId, required String scannedToken});
  Future<void> completeOrder(String orderId);
  Future<String> initPayment(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final http.Client client;

  OrderRemoteDataSourceImpl({required this.client});

  Map<String, String> _getHeaders({required String token}) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String> _getToken() async {
    final localDataSource = di.sl<AuthLocalDataSource>();
    final token = await localDataSource.getLastToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    return token;
  }

  @override
  Future<List<OrderModel>> getMyOrders() async {
    final token = await _getToken();
    final response = await client.get(
      Uri.parse(ApiEndpoints.getMyOrders),
      headers: _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return (data['data'] as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to load orders');
    }
  }

  @override
  Future<OrderModel> createOrder({required String productId, required String deliveryMethod}) async {
    final token = await _getToken();
    final response = await client.post(
      Uri.parse(ApiEndpoints.createOrder),
      headers: _getHeaders(token: token),
      body: jsonEncode({'productId': productId}),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 && data['success'] == true) {
      return OrderModel.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Failed to create order');
    }
  }

  @override
  Future<OrderModel> markShipped(String orderId) async {
    final token = await _getToken();
    final response = await client.put(
      Uri.parse(ApiEndpoints.markOrderShipped(orderId)),
      headers: _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      // Backend markShipped might not return the full order, so we may need to fetch again
      // or just rely on backend returning it if it does. Right now order.controller.js returns { message: "Item marked as shipped" }
      // So we will just call getMyOrders() to find it and return it.
      final orders = await getMyOrders();
      return orders.firstWhere((o) => o.id == orderId);
    } else {
      throw Exception(data['message'] ?? 'Failed to mark as shipped');
    }
  }

  @override
  Future<OrderModel> confirmDelivery({required String orderId, required String scannedToken}) async {
    final token = await _getToken();
    final response = await client.post(
      Uri.parse(ApiEndpoints.confirmDelivery),
      headers: _getHeaders(token: token),
      body: jsonEncode({'orderId': orderId, 'scannedToken': scannedToken}),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final orders = await getMyOrders();
      return orders.firstWhere((o) => o.id == orderId);
    } else {
      throw Exception(data['message'] ?? 'Failed to confirm delivery');
    }
  }

  @override
  Future<void> completeOrder(String orderId) async {
    final token = await _getToken();
    final response = await client.put(
      Uri.parse(ApiEndpoints.completeOrder(orderId)),
      headers: _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to complete order');
    }
  }

  @override
  Future<String> initPayment(String orderId) async {
    final token = await _getToken();
    final response = await client.post(
      Uri.parse(ApiEndpoints.initPayment),
      headers: _getHeaders(token: token),
      body: jsonEncode({'orderId': orderId}),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['checkout_url'];
    } else {
      throw Exception(data['message'] ?? 'Failed to initialize payment');
    }
  }
}
