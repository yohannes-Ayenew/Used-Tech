// lib/features/auth/data/datasources/auth_local_data_source.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:used_tech_client/features/auth/domain/enums/kyc_status.dart';
import 'package:used_tech_client/features/auth/domain/enums/user_role.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getLastToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> logout();
}

const CACHED_TOKEN = 'CACHED_TOKEN';
const CACHED_USER = 'CACHED_USER';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheToken(String token) {
    return sharedPreferences.setString(CACHED_TOKEN, token);
  }

  @override
  Future<String?> getLastToken() async {
    return sharedPreferences.getString(CACHED_TOKEN);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final userJson = jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'role': user.role.toJson(),
      'isPhoneVerified': user.isPhoneVerified,
      'walletBalance': user.walletBalance,
      'isActive': user.isActive,
      'kycStatus': user.kycStatus.toJson(),
      'kycIdImage': user.kycIdImage,
      'kycSubmittedAt': user.kycSubmittedAt?.toIso8601String(),
      'kycReviewedAt': user.kycReviewedAt?.toIso8601String(),
      'kycRejectionReason': user.kycRejectionReason,
    });
    await sharedPreferences.setString(CACHED_USER, userJson);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = sharedPreferences.getString(CACHED_USER);
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel(
        id: userMap['id'] ?? '',
        name: userMap['name'] ?? '',
        email: userMap['email'] ?? '',
        phone: userMap['phone'] ?? '',
        role: UserRole.fromString(userMap['role'] ?? 'USER'),
        token: '',
        isPhoneVerified: userMap['isPhoneVerified'] ?? false,
        walletBalance: (userMap['walletBalance'] ?? 0).toDouble(),
        isActive: userMap['isActive'] ?? true,
        lastLoginAt: userMap['lastLoginAt'] != null
            ? DateTime.parse(userMap['lastLoginAt'])
            : null,
        kycStatus: KycStatus.fromString(userMap['kycStatus'] ?? 'NONE'),
        kycIdImage: userMap['kycIdImage'],
        kycSubmittedAt: userMap['kycSubmittedAt'] != null
            ? DateTime.parse(userMap['kycSubmittedAt'])
            : null,
        kycReviewedAt: userMap['kycReviewedAt'] != null
            ? DateTime.parse(userMap['kycReviewedAt'])
            : null,
        kycRejectionReason: userMap['kycRejectionReason'],
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove(CACHED_TOKEN);
    await sharedPreferences.remove(CACHED_USER);
  }
}
