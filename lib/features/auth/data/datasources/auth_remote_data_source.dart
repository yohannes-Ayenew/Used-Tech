// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import 'auth_local_data_source.dart';
import '../../../../injection_container.dart' as di;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

abstract class AuthRemoteDataSource {
  // Auth methods
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<Map<String, dynamic>> signInWithGoogle();
  Future<void> logout(); // ADDED
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
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? location,
    XFile? profileImage,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> requestVerification({
    required XFile frontImage,
    required XFile backImage,
    required XFile faceImage,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // 💡 serverClientId for Android/iOS, clientId for Web
    serverClientId: kIsWeb
        ? null
        : '440923132786-8rv31b9bhqhtllfj1ok22skbc1u1kdv3.apps.googleusercontent.com',
    clientId: kIsWeb
        ? '440923132786-ljsa2h08f61512lc1fdqflg0nnrq5cu3.apps.googleusercontent.com'
        : null,
  );
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
        return token;
      } else {
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
      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        googleUser = await _googleSignIn.signInSilently();
        if (googleUser == null) {
          await _googleSignIn.signOut();
          googleUser = await _googleSignIn.signIn();
        }
      } else {
        googleUser = await _googleSignIn.signInSilently();
        googleUser ??= await _googleSignIn.signIn();
      }

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
      
      // Removed Force refresh (true) to decrease latency; login always provides a fresh token
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) throw Exception('Failed to get Google ID Token');

      final headers = _getHeaders();
      headers['Connection'] = 'close'; // Prevent TCP connection reuse issues

      final response = await client
          .post(
            Uri.parse(ApiEndpoints.googleLogin),
            body: jsonEncode({'idToken': idToken}),
            headers: headers,
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Google Login failed on server');
      }
    } catch (e) {
      print('❌ Google Sign In Error: $e');
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
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await client.get(
        Uri.parse(ApiEndpoints.getProfile),
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data']; // Assuming backend returns { success: true, data: { ...user } }
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? location,
    XFile? profileImage,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      print('🚀 Updating profile...');

      // 1. Create Multipart Request (PUT)
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(ApiEndpoints.updateProfile),
      );

      // 2. Add Headers (Authorization)
      request.headers['Authorization'] = 'Bearer $token';

      // 3. Add Fields
      if (name != null) request.fields['name'] = name;
      if (phone != null) request.fields['phone'] = phone;
      if (location != null) request.fields['location'] = location;

      // 4. Add Image if provided
      if (profileImage != null) {
        if (kIsWeb) {
          final bytes = await profileImage.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'profileImage',
              bytes,
              filename: profileImage.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        } else {
          // MOBILE: Use path
          final ext = profileImage.path.split('.').last.toLowerCase();
          final mimeType =
              (ext == 'jpg' || ext == 'jpeg') ? 'jpeg' : (ext == 'png' ? 'png' : 'jpeg');
          
          request.files.add(
            await http.MultipartFile.fromPath(
              'profileImage',
              profileImage.path,
              contentType: MediaType('image', mimeType),
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['data']; // Returns updated user object
      } else {
        throw Exception(data['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      print('❌ Profile Update Error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
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
  Future<void> requestVerification({
    required XFile frontImage,
    required XFile backImage,
    required XFile faceImage,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      print('🚀 Uploading verification images...');

      // 1. Create Multipart Request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.requestVerification),
      );

      // 2. Add Headers (Authorization)
      request.headers['Authorization'] = 'Bearer $token';

      // Helper function to add file compatible with Web and Mobile
      Future<void> addFile(String fieldName, XFile file) async {
        if (kIsWeb) {
          // WEB: Read bytes
          final bytes = await file.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              fieldName,
              bytes,
              filename: file.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        } else {
          // MOBILE: Use path
          request.files.add(
            await http.MultipartFile.fromPath(fieldName, file.path),
          );
        }
      }

      // 3. Add all 3 files
      await addFile('frontImage', frontImage);
      await addFile('backImage', backImage);
      await addFile('faceImage', faceImage);

      // 4. Send
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Upload Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        return;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      print('❌ Upload Error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    try {
      print('🚪 Performing full logout (Google + Firebase)...');
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      print('✅ Third-party auth sessions cleared');
    } catch (e) {
      print('⚠️ Error during third-party logout: $e');
    }
  }
}
