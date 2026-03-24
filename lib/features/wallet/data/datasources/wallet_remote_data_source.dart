// lib/features/wallet/data/datasources/wallet_remote_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class WalletRemoteDataSource {
  Future<Map<String, double>> getBalances();
  Future<List<Map<String, dynamic>>> getTransactionHistory();
  Future<void> requestWithdrawal({
    required double amount,
    required String bankName,
    required String accountNumber,
  });
  Future<String> initializeDeposit(double amount);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final http.Client client;

  WalletRemoteDataSourceImpl({required this.client});

  Future<String?> _getToken() async {
    final localDataSource = di.sl<AuthLocalDataSource>();
    return await localDataSource.getLastToken();
  }

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<Map<String, double>> getBalances() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await client.get(
      Uri.parse(ApiEndpoints.getProfile),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return {
        'available': (data['walletBalance'] ?? 0).toDouble(),
        'escrow': (data['escrowBalance'] ?? 0).toDouble(), // This might need backend addition
      };
    } else {
      throw Exception('Failed to fetch balance');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    // Note: Backend might not have a unified endpoint yet, 
    // for now we simulate or fetch from a placeholder if it exists.
    // I'll check for a /api/transactions endpoint in next steps.
    return []; 
  }

  @override
  Future<void> requestWithdrawal({
    required double amount,
    required String bankName,
    required String accountNumber,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await client.post(
      Uri.parse('${ApiEndpoints.baseUrl}/api/withdrawals'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'amount': amount,
        'bankName': bankName,
        'accountNumber': accountNumber,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Withdrawal request failed');
    }
  }

  @override
  Future<String> initializeDeposit(double amount) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await client.post(
      Uri.parse('${ApiEndpoints.baseUrl}/wallets/deposit/initialize'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'amount': amount,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['data'] != null && data['data']['checkoutUrl'] != null) {
        return data['data']['checkoutUrl'];
      }
      return data['checkoutUrl'] ?? '';
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to initialize deposit');
    }
  }
}
