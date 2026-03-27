// lib/features/order/presentation/widgets/order_progress_tracker.dart

import 'package:flutter/material.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import '../../domain/entities/order_entity.dart';

class OrderProgressTracker extends StatelessWidget {
  final OrderStatus status;

  const OrderProgressTracker({super.key, required this.status});

  int get _currentStep {
    switch (status) {
      case OrderStatus.pending:
        return 0; // Payment (Active)
      case OrderStatus.escrowHeld:
        return 1; // Shipped (Payment Done, waiting for shipment)
      case OrderStatus.shipped:
        return 2; // Delivered (Waiting for delivery)
      case OrderStatus.delivered:
      case OrderStatus.disputed:
        return 3; // Complete (Waiting for completion)
      case OrderStatus.completed:
        return 4; // Checkmark on everything
      case OrderStatus.cancelled:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['Paid', 'Shipped', 'In-Transit', 'Complete'];
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final isActive = index <= _currentStep;
            final isCompleted = index < _currentStep;
            
            return Expanded(
              child: Row(
                children: [
                  // Circle
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? context.primaryColor : context.lightGrey,
                      border: Border.all(
                        color: isActive ? context.primaryColor : context.borderColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : context.greyText,
                              ),
                            ),
                    ),
                  ),
                  // Line
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 4,
                        color: index < _currentStep 
                          ? context.primaryColor 
                          : context.lightGrey,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            return Expanded(
              child: Text(
                steps[index],
                textAlign: index == 0 ? TextAlign.left : (index == steps.length -1 ? TextAlign.right : TextAlign.center),
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: index <= _currentStep ? context.darkText : context.greyText,
                  fontWeight: index <= _currentStep ? FontWeight.bold : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
