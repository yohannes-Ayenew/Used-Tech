// lib/features/auth/domain/enums/user_role.dart

import 'package:flutter/material.dart';

enum UserRole {
  user,
  verifiedSeller,
  admin;

  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'VERIFIED_SELLER':
        return UserRole.verifiedSeller;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  String toJson() {
    switch (this) {
      case UserRole.verifiedSeller:
        return 'VERIFIED_SELLER';
      case UserRole.admin:
        return 'ADMIN';
      default:
        return 'USER';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.verifiedSeller:
        return 'Verified Seller';
      case UserRole.admin:
        return 'Admin';
      default:
        return 'User';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.verifiedSeller:
        return Colors.blue;
      case UserRole.admin:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
