// lib/features/auth/domain/enums/user_role.dart

import 'package:flutter/material.dart';

enum UserRole {
  user,
  verifiedSeller,
  admin;

  // Convert from String to UserRole
  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'VERIFIED_SELLER':
        return UserRole.verifiedSeller;
      case 'ADMIN':
        return UserRole.admin;
      case 'USER':
        return UserRole.user;
      default:
        return UserRole.user;
    }
  }

  // Convert from UserRole to String for API
  String toJson() {
    switch (this) {
      case UserRole.verifiedSeller:
        return 'VERIFIED_SELLER';
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.user:
        return 'USER';
    }
  }

  // Get display name
  String get displayName {
    switch (this) {
      case UserRole.verifiedSeller:
        return 'Verified Seller';
      case UserRole.admin:
        return 'Admin';
      case UserRole.user:
        return 'User';
    }
  }

  // Get color for role badge
  Color get color {
    switch (this) {
      case UserRole.verifiedSeller:
        return Colors.blue;
      case UserRole.admin:
        return Colors.purple;
      case UserRole.user:
        return Colors.grey;
    }
  }
}
