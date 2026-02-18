// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../core/constants/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  // Auth methods
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<Map<String, dynamic>> verifyOtp(String userId, String otp);

  // Password reset
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String userId,
    required String token,
    required String newPassword,
  });

  // Profile methods
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

  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json'};
  }

  Map<String, String> _getAuthenticatedHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String> _getToken() async {
    // This will be implemented with secure storage
    throw UnimplementedError('Token retrieval not implemented');
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.login),
        body: jsonEncode({'email': email, 'password': password}),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final message = jsonDecode(response.body)['message'] ?? 'Login failed';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.register),
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
        headers: _getHeaders(),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? 'Registration failed';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String userId, String otp) async {
    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.verifyOtp),
        body: jsonEncode({'userId': userId, 'otp': otp}),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? 'OTP verification failed';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.forgotPassword),
        body: jsonEncode({'email': email}),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send reset email');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> resetPassword({
    required String userId,
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.resetPassword),
        body: jsonEncode({
          'userId': userId,
          'token': token,
          'newPassword': newPassword,
        }),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reset password');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getToken();
      final response = await client.get(
        Uri.parse(ApiEndpoints.getUserProfile),
        headers: _getAuthenticatedHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final token = await _getToken();
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;

      final response = await client.put(
        Uri.parse(ApiEndpoints.updateProfile),
        body: jsonEncode(body),
        headers: _getAuthenticatedHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _getToken();
      final response = await client.post(
        Uri.parse(ApiEndpoints.changePassword),
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
        headers: _getAuthenticatedHeaders(token),
      );

      if (response.statusCode != 200) {
        throw Exception('Password change failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> requestVerification({required File imageFile}) async {
    try {
      final token = await _getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.requestVerification),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'nationalId',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Verification request failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
