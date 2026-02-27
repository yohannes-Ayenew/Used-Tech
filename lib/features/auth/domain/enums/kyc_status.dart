import 'package:flutter/material.dart';

enum KycStatus {
  none,
  pending,
  approved,
  rejected;

  // Converts Database String to Dart Enum
  static KycStatus fromString(String value) {
    // Handle case insensitivity (Approved, approved, APPROVED)
    switch (value.toUpperCase()) {
      case 'PENDING':
        return KycStatus.pending;
      case 'APPROVED':
        return KycStatus.approved;
      case 'VERIFIEDSELLER': // Just in case
      case 'VERIFIED_SELLER': 
        return KycStatus.approved;
      case 'REJECTED':
        return KycStatus.rejected;
      default:
        return KycStatus.none;
    }
  }

  // Converts Enum back to Database String
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

  // Text shown on the Profile Badge
  String get displayName {
    switch (this) {
      case KycStatus.pending:
        return 'Pending Review';
      case KycStatus.approved:
        return 'Verified Seller'; // <--- The text you want
      case KycStatus.rejected:
        return 'Rejected';
      default:
        return 'Not Verified';
    }
  }

  // Color of the Badge
  Color get color {
    switch (this) {
      case KycStatus.pending:
        return Colors.orange;
      case KycStatus.approved:
        return Colors.blue; // <--- The Blue you want
      case KycStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Icon inside the Badge
  IconData get icon {
    switch (this) {
      case KycStatus.pending:
        return Icons.hourglass_empty;
      case KycStatus.approved:
        return Icons.verified; // <--- The Checkmark
      case KycStatus.rejected:
        return Icons.error_outline;
      default:
        return Icons.gpp_bad_outlined;
    }
  }

  // Message shown on Verification Page
  String get message {
    switch (this) {
      case KycStatus.pending:
        return 'Your ID is currently being reviewed by our admins. This usually takes 24 hours.';
      case KycStatus.approved:
        return 'You are fully verified! You can now sell products and withdraw funds.';
      case KycStatus.rejected:
        return 'Your verification was rejected. Please ensure your ID photos are clear and valid.';
      default:
        return 'Verify your ID to get a blue badge and unlock selling features.';
    }
  }
}