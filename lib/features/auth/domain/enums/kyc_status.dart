// lib/features/auth/domain/enums/kyc_status.dart

import 'package:flutter/material.dart';

enum KycStatus {
  none,
  pending,
  approved,
  rejected;

  // Convert from String to KycStatus
  static KycStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return KycStatus.pending;
      case 'APPROVED':
        return KycStatus.approved;
      case 'REJECTED':
        return KycStatus.rejected;
      case 'NONE':
        return KycStatus.none;
      default:
        return KycStatus.none;
    }
  }

  // Convert from KycStatus to String for API
  String toJson() {
    switch (this) {
      case KycStatus.pending:
        return 'PENDING';
      case KycStatus.approved:
        return 'APPROVED';
      case KycStatus.rejected:
        return 'REJECTED';
      case KycStatus.none:
        return 'NONE';
    }
  }

  // Get display name
  String get displayName {
    switch (this) {
      case KycStatus.pending:
        return 'Pending Review';
      case KycStatus.approved:
        return 'Verified';
      case KycStatus.rejected:
        return 'Rejected';
      case KycStatus.none:
        return 'Not Verified';
    }
  }

  // Get status color
  Color get color {
    switch (this) {
      case KycStatus.pending:
        return Colors.orange;
      case KycStatus.approved:
        return Colors.green;
      case KycStatus.rejected:
        return Colors.red;
      case KycStatus.none:
        return Colors.grey;
    }
  }

  // Get status icon
  IconData get icon {
    switch (this) {
      case KycStatus.pending:
        return Icons.hourglass_empty;
      case KycStatus.approved:
        return Icons.verified;
      case KycStatus.rejected:
        return Icons.error_outline;
      case KycStatus.none:
        return Icons.verified_outlined;
    }
  }

  // Get status message
  String get message {
    switch (this) {
      case KycStatus.pending:
        return 'Your ID is being reviewed by admin';
      case KycStatus.approved:
        return 'You are a verified seller!';
      case KycStatus.rejected:
        return 'Verification rejected. Please submit a valid ID';
      case KycStatus.none:
        return 'Verify your ID to get a blue badge';
    }
  }
}
