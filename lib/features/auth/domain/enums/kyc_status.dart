// lib/features/auth/domain/enums/kyc_status.dart

import 'package:flutter/material.dart';

enum KycStatus {
  none,
  pending,
  approved,
  rejected;

  static KycStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return KycStatus.pending;
      case 'APPROVED':
        return KycStatus.approved;
      case 'REJECTED':
        return KycStatus.rejected;
      default:
        return KycStatus.none;
    }
  }

  String toJson() {
    switch (this) {
      case KycStatus.pending:
        return 'PENDING';
      case KycStatus.approved:
        return 'APPROVED';
      case KycStatus.rejected:
        return 'REJECTED';
      default:
        return 'NONE';
    }
  }

  String get displayName {
    switch (this) {
      case KycStatus.pending:
        return 'Pending Review';
      case KycStatus.approved:
        return 'Verified Seller';
      case KycStatus.rejected:
        return 'Rejected';
      default:
        return 'Not Verified';
    }
  }

  Color get color {
    switch (this) {
      case KycStatus.pending:
        return Colors.orange;
      case KycStatus.approved:
        return Colors.green;
      case KycStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case KycStatus.pending:
        return Icons.hourglass_empty;
      case KycStatus.approved:
        return Icons.verified;
      case KycStatus.rejected:
        return Icons.error_outline;
      default:
        return Icons.verified_outlined;
    }
  }

  String get message {
    switch (this) {
      case KycStatus.pending:
        return 'Your ID is being reviewed by admin';
      case KycStatus.approved:
        return 'You are a verified seller!';
      case KycStatus.rejected:
        return 'Verification rejected. Please submit a valid ID';
      default:
        return 'Verify your ID to get a blue badge';
    }
  }
}
