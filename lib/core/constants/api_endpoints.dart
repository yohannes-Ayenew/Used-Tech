// lib/core/constants/api_endpoints.dart

import 'package:flutter/foundation.dart';  

class ApiEndpoints {
  // Logic to switch URL based on platform
  // WE REMOVED "static const String baseUrl = ..." to avoid the duplicate error
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else {
      // 💡 TIP: Your IP changed from 10.232.201.96 to 10.232.201.120
      // Run 'ipconfig' and look for Ethernet adapter IPv4 Address
      const String localIp = '10.232.201.120';   
      return 'http://$localIp:3000/api'; 
    }
  }

  // ALL endpoints below must be getters ('get') because baseUrl is dynamic now
  static String get test => '$baseUrl/users/test';
  static String get register => '$baseUrl/users/register';
  static String get verifyEmail => '$baseUrl/users/verify-email';
  static String get resendOTP => '$baseUrl/users/resend-otp';
  static String get login => '$baseUrl/users/login';
  static String get googleLogin => '$baseUrl/users/google';
  static String get forgotPassword => '$baseUrl/users/forgot-password';
  static String get resetPassword => '$baseUrl/users/reset-password';
  static String get getProfile => '$baseUrl/users/me';
  static String get updateProfile => '$baseUrl/users/profile';
  static String get changePassword => '$baseUrl/users/change-password';
  static String get requestVerification => '$baseUrl/users/request-verification';
}