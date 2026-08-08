import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:used_tech_client/core/constants/api_endpoints.dart';
import 'package:used_tech_client/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:used_tech_client/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:used_tech_client/injection_container.dart' as di;

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  final String? token;
  FakeAuthLocalDataSource({this.token = 'fake_jwt_token'});

  @override
  Future<String?> getLastToken() async => token;

  @override
  Future<void> cacheToken(String token) async {}

  @override
  Future<void> clearToken() async {}

  @override
  Future<bool> hasToken() async => token != null;
}

void main() {
  setUp(() async {
    await di.sl.reset();
    di.sl.registerLazySingleton<AuthLocalDataSource>(() => FakeAuthLocalDataSource());
  });

  tearDown(() async {
    await di.sl.reset();
  });

  group('WalletRemoteDataSourceImpl Tests', () {
    test('getBalances should parse wallet and escrow balances on 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), equals(ApiEndpoints.getProfile));
        expect(request.headers['Authorization'], equals('Bearer fake_jwt_token'));
        return http.Response(
          jsonEncode({
            'status': 'success',
            'data': {
              'walletBalance': 1250.50,
              'escrowBalance': 300.00,
            }
          }),
          200,
        );
      });

      final dataSource = WalletRemoteDataSourceImpl(client: mockClient);
      final balances = await dataSource.getBalances();

      expect(balances['available'], equals(1250.50));
      expect(balances['escrow'], equals(300.00));
    });

    test('initializeDeposit should return checkoutUrl on success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), equals(ApiEndpoints.initDeposit));
        return http.Response(
          jsonEncode({
            'status': 'success',
            'data': {
              'checkoutUrl': 'https://checkout.chapa.co/pay/test-ref-123'
            }
          }),
          200,
        );
      });

      final dataSource = WalletRemoteDataSourceImpl(client: mockClient);
      final checkoutUrl = await dataSource.initializeDeposit(500.0);

      expect(checkoutUrl, equals('https://checkout.chapa.co/pay/test-ref-123'));
    });

    test('requestWithdrawal should complete successfully on 201 Created', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), equals(ApiEndpoints.requestWithdrawal));
        return http.Response(
          jsonEncode({'message': 'Withdrawal request submitted successfully'}),
          201,
        );
      });

      final dataSource = WalletRemoteDataSourceImpl(client: mockClient);

      expect(
        dataSource.requestWithdrawal(
          amount: 200.0,
          bankName: 'Commercial Bank of Ethiopia',
          accountNumber: '100012345678',
        ),
        completes,
      );
    });

    test('requestWithdrawal should throw exception on failure response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Insufficient funds in wallet'}),
          400,
        );
      });

      final dataSource = WalletRemoteDataSourceImpl(client: mockClient);

      expect(
        () => dataSource.requestWithdrawal(
          amount: 5000.0,
          bankName: 'CBE',
          accountNumber: '100012345678',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
