// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import 'auth_local_data_source.dart';
import '../../../../injection_container.dart' as di;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  // Auth methods
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<Map<String, dynamic>> signInWithGoogle(); // ADDED
  Future<Map<String, dynamic>> verifyEmail(String userId, String otp);
  Future<Map<String, dynamic>> resendOTP(String email);

  // Password reset
  Future<Map<String, dynamic>> forgotPassword(String email);
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
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
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthRemoteDataSourceImpl({required this.client});

  Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<String?> _getToken() async {
    try {
      final localDataSource = di.sl<AuthLocalDataSource>();
      final token = await localDataSource.getLastToken();

      if (token != null && token.isNotEmpty) {
        print('📝 Token retrieved: ${token.substring(0, 10)}...');
        return token;
      } else {
        print('❌ No token found in local storage');
        return null;
      }
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
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
      final body = {'name': name, 'email': email, 'password': password};
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

  // --- NEW GOOGLE SIGN IN METHOD ---
  @override
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google Sign In cancelled');

      // 2. Obtain the auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase to get the Firebase ID Token
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) throw Exception('Failed to get Google ID Token');

      // 5. Send ID Token to YOUR Backend
      print('🚀 Sending Google Token to Backend...');
      final response = await client.post(
        Uri.parse(ApiEndpoints.googleLogin),
        body: jsonEncode({'idToken': idToken}),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Google Login failed on server');
      }
    } catch (e) {
      print('❌ Google Sign In Error: $e');
      throw Exception(e.toString());
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
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await client
          .post(
            Uri.parse(ApiEndpoints.forgotPassword),
            body: jsonEncode({'email': email}),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to send reset code');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
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

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    throw UnimplementedError('getUserProfile not implemented yet');
  }

  @override
  Future<Map<String, dynamic>> updateProfile({String? name, String? phone}) {
    throw UnimplementedError('updateProfile not implemented yet');
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      final response = await client
          .post(
            Uri.parse(ApiEndpoints.changePassword),
            body: jsonEncode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
            headers: _getHeaders(token: token),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception(data['message'] ?? 'Failed to change password');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> requestVerification({required File imageFile}) {
    throw UnimplementedError('requestVerification not implemented yet');
  }
}
