// lib/features/product/presentation/widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import '../pages/product_detail_page.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String title;
  final String price;
  final String condition;
  final String location;
  final bool isVerified;
  final bool isEscrow;

  const ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.condition,
    required this.location,
    required this.isVerified,
    this.isEscrow = true,
  });

  Color _getConditionColor(BuildContext context, String condition) {
    switch (condition.toLowerCase()) {
      case 'like new':
        return Colors.green;
      case 'good':
        return Colors.orange;
      case 'fair':
        return Colors.red;
      default:
        return context.pillText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductDetailPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Add this
          children: [
            // Image with fixed aspect ratio
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: context.lightGrey,
                      child: Icon(
                        Icons.image_not_supported,
                        color: context.greyText,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Content with proper spacing
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$price ETB",
                    maxLines: 1, // Add this
                    overflow: TextOverflow.ellipsis, // Add this
                    style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Condition Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getConditionColor(
                        context,
                        condition,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      condition,
                      style: TextStyle(
                        color: _getConditionColor(context, condition),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Location & Badges
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 10,
                        color: context.greyText,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          location,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4), // Increased from 2
                      // Badges
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isVerified)
                            Icon(
                              Icons.verified,
                              size: 12, // Slightly larger
                              color: Colors.blue,
                            ),
                          if (isVerified && isEscrow) const SizedBox(width: 2),
                          if (isEscrow)
                            Icon(
                              Icons.security,
                              size: 12, // Slightly larger
                              color: Colors.green,
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
