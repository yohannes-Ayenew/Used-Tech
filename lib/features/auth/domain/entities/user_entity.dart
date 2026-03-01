// lib/features/auth/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';
import '../enums/user_role.dart';
import '../enums/kyc_status.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final UserRole role;
  final String token;
  final bool isEmailVerified;
  final double walletBalance;
  final bool isActive;
  final String? location;
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
    this.phone,
    this.profileImage,
    required this.role,
    required this.token,
    required this.isEmailVerified,
    required this.walletBalance,
    required this.isActive,
    this.location,
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

  bool get canSell => isEmailVerified && isActive;

  @override
  List<Object?> get props => [
    id,
    email,
    role,
    isEmailVerified,
    kycStatus,
    walletBalance,
    isActive,
    location,
  ];

  UserEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    UserRole? role,
    double? walletBalance,
    bool? isEmailVerified,
    bool? isActive,
    String? location,
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
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      token: token,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      walletBalance: walletBalance ?? this.walletBalance,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      kycStatus: kycStatus ?? this.kycStatus,
      kycIdImage: kycIdImage ?? this.kycIdImage,
      kycSubmittedAt: kycSubmittedAt ?? this.kycSubmittedAt,
      kycReviewedAt: kycReviewedAt ?? this.kycReviewedAt,
      kycRejectionReason: kycRejectionReason ?? this.kycRejectionReason,
    );
  }
}
