import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';

class ProductShimmer extends StatelessWidget {
  const ProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = context.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Placeholder
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
            ),

            // Content Placeholder
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Price
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Condition Pill
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location Row
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 100,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
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

class ProductShimmerList extends StatelessWidget {
  final Axis scrollDirection;
  final int itemCount;
  final double? height;
  final double width;
  final bool isGrid;

  const ProductShimmerList({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.itemCount = 5,
    this.height,
    this.width = 160,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7, // Adjust to match ProductCard
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => const ProductShimmer(),
      );
    }

    return SizedBox(
      height: height ?? 280,
      child: ListView.separated(
        scrollDirection: scrollDirection,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) => SizedBox(
          width: width,
          child: const ProductShimmer(),
        ),
      ),
    );
  }
}
