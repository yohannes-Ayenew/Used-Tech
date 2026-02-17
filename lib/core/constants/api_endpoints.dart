// lib/core/constants/api_endpoints.dart

class ApiEndpoints {
  static const String baseUrl =
      'https://ecommerce-backend-saje.onrender.com/api';

  // Auth endpoints
  static const String login = '$baseUrl/users/login';
  static const String register = '$baseUrl/users/register';
  static const String verifyOtp = '$baseUrl/users/verify-otp';
  static const String forgotPassword = '$baseUrl/users/forgot-password';
  static const String resetPassword = '$baseUrl/users/reset-password';

  // Profile endpoints
  static const String getUserProfile = '$baseUrl/users/me';
  static const String updateProfile = '$baseUrl/users/profile';
  static const String changePassword = '$baseUrl/users/change-password';

  // KYC endpoints
  static const String requestVerification =
      '$baseUrl/users/request-verification';

  // Admin endpoints
  static const String adminPendingVerifications =
      '$baseUrl/users/admin/pending-verifications';
  static const String adminVerifyUser = '$baseUrl/users/admin/verify-user';
}
