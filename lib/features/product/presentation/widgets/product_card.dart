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
              padding: const EdgeInsets.all(8.0), // Reduced from 10 to 8
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: 13, // Slightly smaller
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced spacing
                  // Price
                  Text(
                    "$price ETB",
                    style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 14, // Slightly smaller
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced spacing
                  // Condition Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ), // Smaller padding
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
                        fontSize: 9, // Smaller font
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced spacing
                  // Location & Badges
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 10,
                        color: context.greyText,
                      ), // Smaller icon
                      const SizedBox(width: 2),
                      Expanded(
                        // Wrap location in Expanded to prevent overflow
                        child: Text(
                          location,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      // Badges
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isVerified)
                            Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified,
                                size: 10,
                                color: Colors.blue,
                              ),
                            ),
                          if (isVerified && isEscrow) const SizedBox(width: 2),
                          if (isEscrow)
                            Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.security,
                                size: 10,
                                color: Colors.green,
                              ),
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
