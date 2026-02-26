// lib/features/auth/data/models/user_model.dart

import '../../domain/entities/user_entity.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/enums/kyc_status.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.role,
    required super.token,
    required super.isEmailVerified,
    required super.walletBalance,
    required super.isActive,
    super.lastLoginAt,
    required super.kycStatus,
    super.kycIdImage,
    super.kycSubmittedAt,
    super.kycReviewedAt,
    super.kycRejectionReason,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: UserRole.fromString(json['role'] ?? 'USER'),
      token: json['token'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      kycStatus: KycStatus.fromString(json['kyc']?['status'] ?? 'NONE'),
      kycIdImage: json['kyc']?['idImage'],
      kycSubmittedAt: json['kyc']?['submittedAt'] != null
          ? DateTime.parse(json['kyc']['submittedAt'])
          : null,
      kycReviewedAt: json['kyc']?['reviewedAt'] != null
          ? DateTime.parse(json['kyc']['reviewedAt'])
          : null,
      kycRejectionReason: json['kyc']?['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toJson(),
      'isEmailVerified': isEmailVerified,
      'walletBalance': walletBalance,
      'isActive': isActive,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'kyc': {
        'status': kycStatus.toJson(),
        'idImage': kycIdImage,
        'submittedAt': kycSubmittedAt?.toIso8601String(),
        'reviewedAt': kycReviewedAt?.toIso8601String(),
        'rejectionReason': kycRejectionReason,
      },
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    double? walletBalance,
    bool? isEmailVerified,
    bool? isActive,
    DateTime? lastLoginAt,
    KycStatus? kycStatus,
    String? kycIdImage,
    DateTime? kycSubmittedAt,
    DateTime? kycReviewedAt,
    String? kycRejectionReason,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
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