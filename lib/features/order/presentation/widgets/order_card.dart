// lib/features/order/presentation/widgets/order_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import '../../domain/entities/order_entity.dart';
import 'order_progress_tracker.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final bool isSelling;
  final VoidCallback? onAccept;
  final VoidCallback? onReport;
  final VoidCallback? onViewDetails;

  const OrderCard({
    super.key,
    required this.order,
    this.isSelling = false,
    this.onAccept,
    this.onReport,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: order.productImage,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: context.lightGrey),
                    errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productTitle,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${order.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ETB",
                        style: context.textTheme.titleLarge?.copyWith(
                          color: context.primaryColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Order ID: ${order.id}",
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: order.status.color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(order.status),
                      size: 14,
                      color: order.status.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: order.status.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Progress Tracker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OrderProgressTracker(status: order.status),
          ),

          const SizedBox(height: 20),

          const Divider(height: 1),

          // Action Area
          if (order.status == OrderStatus.delivered && !isSelling)
             Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.orange[800]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Inspection Period: 19h 53m remaining",
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.successColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Accept Item"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Report Issue"),
                          ),
                        ),
                      ],
                    ),
                 ],
               ),
             )
          else
            InkWell(
              onTap: onViewDetails,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "View Details",
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: context.primaryColor, size: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Icons.access_time;
      case OrderStatus.escrowHeld: return Icons.security;
      case OrderStatus.shipped: return Icons.local_shipping;
      case OrderStatus.delivered: return Icons.check_circle_outline;
      case OrderStatus.completed: return Icons.verified;
      case OrderStatus.disputed: return Icons.warning_amber;
      case OrderStatus.cancelled: return Icons.cancel_outlined;
    }
  }
}
