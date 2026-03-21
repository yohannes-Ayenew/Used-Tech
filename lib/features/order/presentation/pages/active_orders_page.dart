// lib/features/order/presentation/pages/active_orders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/order/presentation/bloc/order_bloc.dart';
import 'package:used_tech_client/features/order/presentation/bloc/order_event.dart';
import 'package:used_tech_client/features/order/presentation/bloc/order_state.dart';
import 'package:used_tech_client/features/order/presentation/widgets/order_card.dart';

class ActiveOrdersPage extends StatefulWidget {
  const ActiveOrdersPage({super.key});

  @override
  State<ActiveOrdersPage> createState() => _ActiveOrdersPageState();
}

class _ActiveOrdersPageState extends State<ActiveOrdersPage> {
  bool _isBuyingSelected = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    if (_isBuyingSelected) {
      context.read<OrderBloc>().add(GetMyOrdersEvent());
    } else {
      context.read<OrderBloc>().add(GetMySalesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white60),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Active Orders",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Custom Toggle
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: context.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isBuyingSelected = true;
                          _fetchOrders();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isBuyingSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "Buying",
                            style: TextStyle(
                              color: _isBuyingSelected ? context.primaryColor : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isBuyingSelected = false;
                          _fetchOrders();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isBuyingSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "Selling",
                            style: TextStyle(
                              color: !_isBuyingSelected ? context.primaryColor : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Order List
          Expanded(
            child: BlocConsumer<OrderBloc, OrderState>(
              listener: (context, state) {
                if (state is OrderStatusUpdated) {
                  _fetchOrders();
                }
              },
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is OrderError) {
                  return Center(child: Text(state.message));
                } else if (state is OrdersLoaded || state is SalesLoaded) {
                  final orders = state is OrdersLoaded ? state.orders : (state as SalesLoaded).sales;
                  
                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: context.greyText.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            _isBuyingSelected ? "No buying orders yet" : "No active sales",
                            style: context.textTheme.titleMedium?.copyWith(color: context.greyText),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return OrderCard(
                        order: orders[index],
                        isSelling: !_isBuyingSelected,
                        onAccept: () {
                          context.read<OrderBloc>().add(AcceptOrderEvent(orderId: orders[index].id));
                        },
                        onReport: () {
                          // TODO: Show report dialog
                        },
                        onViewDetails: () {
                          Navigator.pushNamed(
                            context, 
                            '/order-details', 
                            arguments: orders[index].id,
                          );
                        },
                      );
                    },
                  );
                } else if (state is OrderStatusUpdated || state is OrderDetailsLoaded) {
                   // While refreshing after an action, show the previous state if possible, 
                   // or just show a loading indicator.
                   return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
