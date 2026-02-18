// lib/features/auth/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';
import '../enums/user_role.dart';
import '../enums/kyc_status.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String token;
  final bool isPhoneVerified;
  final double walletBalance;
  final bool isActive;
  final DateTime? lastLoginAt;

  // KYC fields
  final KycStatus kycStatus;
  final String? kycIdImage;
  final DateTime? kycSubmittedAt;
  final DateTime? kycReviewedAt;
  final String? kycRejectionReason;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.token,
    required this.isPhoneVerified,
    required this.walletBalance,
    required this.isActive,
    this.lastLoginAt,
    required this.kycStatus,
    this.kycIdImage,
    this.kycSubmittedAt,
    this.kycReviewedAt,
    this.kycRejectionReason,
  });

  // Helper getters
  bool get isVerifiedSeller => role == UserRole.verifiedSeller;
  bool get isAdmin => role == UserRole.admin;
  bool get isKycPending => kycStatus == KycStatus.pending;
  bool get isKycApproved => kycStatus == KycStatus.approved;
  bool get isKycRejected => kycStatus == KycStatus.rejected;

  bool get canRequestVerification =>
      !isVerifiedSeller && kycStatus != KycStatus.pending && isActive;

  bool get canSell => isPhoneVerified && isActive;

  @override
  List<Object?> get props => [
    id,
    email,
    role,
    isPhoneVerified,
    kycStatus,
    walletBalance,
    isActive,
  ];

  UserEntity copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    double? walletBalance,
    bool? isPhoneVerified,
    bool? isActive,
    DateTime? lastLoginAt,
    KycStatus? kycStatus,
    String? kycIdImage,
    DateTime? kycSubmittedAt,
    DateTime? kycReviewedAt,
    String? kycRejectionReason,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      walletBalance: walletBalance ?? this.walletBalance,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      kycStatus: kycStatus ?? this.kycStatus,
      kycIdImage: kycIdImage ?? this.kycIdImage,
      kycSubmittedAt: kycSubmittedAt ?? this.kycSubmittedAt,
      kycReviewedAt: kycReviewedAt ?? this.kycReviewedAt,
      kycRejectionReason: kycRejectionReason ?? this.kycRejectionReason,
    );
  }
}
