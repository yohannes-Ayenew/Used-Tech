// lib/core/constants/api_endpoints.dart

class ApiEndpoints {
  // Change this to your actual backend URL
  static const String baseUrl = 'http://localhost:3000/api';
  // For production: 'https://ecommerce-backend-saje.onrender.com/api'

  // Auth endpoints
  static const String test = '$baseUrl/users/test';
  static const String register = '$baseUrl/users/register';
  static const String googleLogin = '$baseUrl/users/google';
  static const String verifyEmail = '$baseUrl/users/verify-email';
  static const String resendOTP = '$baseUrl/users/resend-otp';
  static const String login = '$baseUrl/users/login';
  static const String forgotPassword = '$baseUrl/users/forgot-password';
  static const String resetPassword = '$baseUrl/users/reset-password';
  static const String getProfile = '$baseUrl/users/me';
  static const String updateProfile = '$baseUrl/users/profile';
  static const String changePassword = '$baseUrl/users/change-password';
}
