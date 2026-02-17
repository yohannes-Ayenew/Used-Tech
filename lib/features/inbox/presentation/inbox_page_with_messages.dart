// lib/features/inbox/presentation/pages/inbox_page_with_messages.dart

import 'package:flutter/material.dart';
import '../../../core/constants/global_variables.dart';

class InboxPageWithMessages extends StatelessWidget {
  const InboxPageWithMessages({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data based on your image
    final List<Map<String, dynamic>> messages = [
      {
        'product': 'iPhone 13 Pro',
        'seller': 'Abebe Tesfa',
        'price': '50,000 ETB',
        'message': 'Is it still available?',
        'time': '2 min ago',
        'unread': true,
        'status': 'Escrow Active',
        'statusColor': Colors.green,
      },
      {
        'product': 'MacBook Air M1',
        'seller': 'Sara Kebede',
        'price': '85,000 ETB',
        'message': 'When can we meet?',
        'time': '1 hour ago',
        'unread': false,
        'status': null,
        'statusColor': null,
      },
      {
        'product': 'Samsung Galaxy S21',
        'seller': 'Dawit Alemayehu',
        'price': '32,000 ETB',
        'message': 'Thanks! Received it.',
        'time': '2 days ago',
        'unread': false,
        'status': 'Completed',
        'statusColor': Colors.blue,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Inbox",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF1F2937)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Unread count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${messages.where((m) => m['unread']).length} unread messages",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: msg['unread']
                        ? GlobalVariables.primaryTeal.withOpacity(0.02)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: msg['unread']
                          ? GlobalVariables.primaryTeal.withOpacity(0.3)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Placeholder
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: GlobalVariables.lightGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.phone_android,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Message Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    msg['product'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  msg['time'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${msg['seller']} • ${msg['price']}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              msg['message'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: msg['unread']
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: msg['unread']
                                    ? Color(0xFF1F2937)
                                    : Colors.grey[700],
                              ),
                            ),
                            if (msg['status'] != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (msg['statusColor'] ?? Colors.green)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (msg['status'] == 'Escrow Active')
                                      const Icon(
                                        Icons.security,
                                        size: 12,
                                        color: Colors.green,
                                      ),
                                    if (msg['status'] == 'Completed')
                                      const Icon(
                                        Icons.check_circle,
                                        size: 12,
                                        color: Colors.blue,
                                      ),
                                    const SizedBox(width: 4),
                                    Text(
                                      msg['status'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            msg['statusColor'] ?? Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
