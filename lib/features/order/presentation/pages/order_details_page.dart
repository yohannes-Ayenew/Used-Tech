import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/core/constants/api_endpoints.dart';
import 'package:used_tech_client/features/order/domain/entities/order_entity.dart';
import 'package:used_tech_client/features/order/presentation/bloc/order_bloc.dart';
import 'package:used_tech_client/features/order/presentation/bloc/order_event.dart';
import 'package:used_tech_client/features/order/presentation/bloc/order_state.dart';
import 'package:used_tech_client/features/order/presentation/widgets/order_progress_tracker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:used_tech_client/injection_container.dart';
import 'package:used_tech_client/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:used_tech_client/features/wallet/presentation/pages/payment_webview_page.dart';
import 'dart:async';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String? _currentUserId;
  Timer? _countdownTimer;
  Timer? _statusPollingTimer;
  String _remainingTime = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
    context.read<OrderBloc>().add(GetOrderDetailsEvent(orderId: widget.orderId));
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _statusPollingTimer?.cancel();
    super.dispose();
  }

  void _startStatusPolling() {
    _statusPollingTimer?.cancel();
    _statusPollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        context.read<OrderBloc>().add(GetOrderDetailsEvent(orderId: widget.orderId));
      }
    });
  }

  void _stopStatusPolling() {
    _statusPollingTimer?.cancel();
    _statusPollingTimer = null;
  }

  void _startTimer(DateTime autoConfirmAt) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = autoConfirmAt.difference(now);

      if (difference.isNegative) {
        timer.cancel();
        if (mounted) setState(() => _remainingTime = "Expired");
      } else {
        if (mounted) {
          setState(() {
            final hours = difference.inHours;
            final minutes = difference.inMinutes.remainder(60);
            final seconds = difference.inSeconds.remainder(60);
            _remainingTime = "${hours}h ${minutes}m ${seconds}s";
          });
        }
      }
    });
  }

  Future<void> _loadUser() async {
    final user = await sl<AuthLocalDataSource>().getCachedUser();
    if (mounted) {
      setState(() {
        _currentUserId = user?.id;
      });
    }
  }

  void _openScanner(String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue == orderId) {
                Navigator.pop(context);
                context.read<OrderBloc>().add(
                  ConfirmDeliveryEvent(orderId: orderId, scannedToken: barcode.rawValue!),
                );
                return;
              }
            }
          },
        ),
      ),
    );
  }

  void _showQRCode(String orderId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Delivery Confirmation QR",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Ask the seller to scan this code upon meetup.",
              style: TextStyle(color: context.greyText, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            QrImageView(
              data: orderId,
              version: QrVersions.auto,
              size: 200.0,
              foregroundColor: context.primaryColor,
            ),
            const SizedBox(height: 30),
            Text(
              "Order ID: $orderId",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrackingDialog(String orderId) {
    final trackingController = TextEditingController();
    final courierController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Enter Shipping Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courierController,
              decoration: const InputDecoration(
                labelText: "Courier Name (e.g. DHL, EMS, Local)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: trackingController,
              decoration: const InputDecoration(
                labelText: "Tracking Number",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (courierController.text.isNotEmpty && trackingController.text.isNotEmpty) {
                context.read<OrderBloc>().add(
                  UpdateOrderStatusEvent(
                    orderId: orderId,
                    status: OrderStatus.shipped,
                    trackingNumber: trackingController.text,
                    courierName: courierController.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: sl<ThemeData>().primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Confirm Shipment", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReportIssueDialog(String orderId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Report an Issue"),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Describe the issue with the item...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                context.read<OrderBloc>().add(
                  ReportOrderIssueEvent(orderId: orderId, reason: reasonController.text),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Submit Report", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Order Details",
          style: TextStyle(color: context.darkText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderDetailsLoaded) {
            if (state.order.status == OrderStatus.pending) {
              _startStatusPolling();
            } else {
              _stopStatusPolling();
            }
            if (state.order.status == OrderStatus.delivered) {
              if (state.order.autoConfirmAt != null) {
                _startTimer(state.order.autoConfirmAt!);
              }
            }
          }
          if (state is OrderStatusUpdated) {
             if (state.order.status == OrderStatus.pending) {
              _startStatusPolling();
            } else {
              _stopStatusPolling();
            }
            if (state.order.status == OrderStatus.delivered) {
              if (state.order.autoConfirmAt != null) {
                _startTimer(state.order.autoConfirmAt!);
              }
            }
          }
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderError) {
            return Center(child: Text(state.message));
          } else if (state is OrderDetailsLoaded || (state is OrderStatusUpdated)) {
            final order = (state is OrderDetailsLoaded) ? state.order : (state as OrderStatusUpdated).order;
            final isBuyer = _currentUserId == order.buyerId;
            final isSeller = _currentUserId == order.sellerId;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OrderBloc>().add(GetOrderDetailsEvent(orderId: order.id));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: ApiEndpoints.resolveImageUrl(order.productImage),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.productTitle,
                                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${order.formattedAmount} ETB",
                                style: TextStyle(
                                  color: context.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Inspection Timer (Delivered state only)
                  if (order.status == OrderStatus.delivered)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Inspection Period Ends In:",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _remainingTime,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Order Status & Progress
                  Text(
                    "Order Status",
                    style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        OrderProgressTracker(status: order.status),
                        const SizedBox(height: 24),
                        Text(
                          "Current Status: ${order.status.displayName}",
                          style: TextStyle(
                            color: order.status.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Shipping Info (Mock)
                  Text(
                    "Transaction Details",
                    style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(context, "Order ID", order.id),
                        _buildInfoRow(context, "Seller", order.sellerName),
                        _buildInfoRow(context, "Buyer", order.buyerName),
                        _buildInfoRow(context, "Date", "Mar 21, 2026"),
                        _buildInfoRow(context, "Payment", "Escrow Held", isLast: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Action Buttons
                  if (isBuyer && order.status == OrderStatus.pending)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payment_rounded),
                        label: const Text("Pay Now (Secure Escrow)", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          context.read<OrderBloc>().add(InitPaymentEvent(orderId: order.id));
                          
                          // Show loading dialog similar to ProductDetailPage
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => BlocListener<OrderBloc, OrderState>(
                              listener: (context, state) {
                                if (state is PaymentInitialized) {
                                  Navigator.pop(ctx);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentWebViewPage(
                                        checkoutUrl: state.checkoutUrl,
                                        title: "Escrow Payment",
                                      ),
                                    ),
                                  ).then((_) {
                                    context.read<OrderBloc>().add(GetOrderDetailsEvent(orderId: order.id));
                                  });
                                } else if (state is OrderError) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                                  );
                                }
                              },
                              child: AlertDialog(
                                content: Row(
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(width: 20),
                                    const Expanded(child: Text("Initializing Payment...")),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),

                  if (isBuyer && (order.status == OrderStatus.shipped || order.status == OrderStatus.escrowHeld))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.qr_code_2_rounded),
                        label: const Text("Show Delivery QR", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _showQRCode(order.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),

                  if (isSeller && (order.status == OrderStatus.escrowHeld))
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.local_shipping_rounded),
                            label: const Text("Mark as Shipped (Courier)", style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => _showTrackingDialog(order.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                            label: const Text("Confirm Meetup Delivery (Scan QR)", style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => _openScanner(order.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (isSeller && (order.status == OrderStatus.shipped))
                     SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text("Scan Buyer's QR to Confirm Delivery", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _openScanner(order.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),

                  if (isBuyer && order.status == OrderStatus.delivered)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<OrderBloc>().add(AcceptOrderEvent(orderId: order.id));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.successColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text("Accept & Pay Seller", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showReportIssueDialog(order.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text("Report Issue", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              )
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: context.greyText, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
