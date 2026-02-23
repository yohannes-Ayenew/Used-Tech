// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<Map<String, dynamic>> verifyEmail(String userId, String otp);
  Future<Map<String, dynamic>> resendOTP(String email);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<Map<String, dynamic>> getUserProfile();
  Future<Map<String, dynamic>> updateProfile({String? name, String? phone});
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> requestVerification({required File imageFile});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await client
          .post(
            Uri.parse(ApiEndpoints.login),
            body: jsonEncode({'email': email, 'password': password}),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 403) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'password': password,
      };
      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
      }

      final response = await client
          .post(
            Uri.parse(ApiEndpoints.register),
            body: jsonEncode(body),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Map<String, dynamic>> verifyEmail(String userId, String otp) async {
    try {
      final response = await client
          .post(
            Uri.parse(ApiEndpoints.verifyEmail),
            body: jsonEncode({'userId': userId, 'otp': otp}),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Verification failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Map<String, dynamic>> resendOTP(String email) async {
    try {
      final response = await client
          .post(
            Uri.parse(ApiEndpoints.resendOTP),
            body: jsonEncode({'email': email}),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await client
          .post(
            Uri.parse(ApiEndpoints.forgotPassword),
            body: jsonEncode({'email': email}),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to send reset email');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse(ApiEndpoints.resetPassword),
            body: jsonEncode({
              'email': email,
              'otp': otp,
              'newPassword': newPassword,
            }),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    // This will be implemented with token
    throw UnimplementedError('Will be implemented with token auth');
  }

  @override
  Future<Map<String, dynamic>> updateProfile({String? name, String? phone}) {
    throw UnimplementedError();
  }

  @override
  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) {
    throw UnimplementedError();
  }

  @override
  Future<void> requestVerification({required File imageFile}) {
    throw UnimplementedError();
  }
}
