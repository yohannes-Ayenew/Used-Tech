// lib/features/profile/presentation/widgets/verification_badge.dart

import 'package:flutter/material.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';

class VerificationBadge extends StatelessWidget {
  final bool isVerified;
  final double size;

  const VerificationBadge({
    super.key,
    required this.isVerified,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.primaryColor,
        shape: BoxShape.circle,
        border: Border.all(color: context.cardBackground, width: 2),
      ),
      child: Center(
        child: Icon(Icons.check, color: Colors.white, size: size * 0.6),
      ),
    );
  }
}
