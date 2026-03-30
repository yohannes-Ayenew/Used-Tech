import 'package:used_tech_client/core/services/socket_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;
  final SocketService socketService;
  StreamSubscription? _socketSubscription;

  OrderBloc({
    required this.orderRepository,
    required this.socketService,
  }) : super(OrderInitial()) {
    on<GetMyOrdersEvent>(_onGetMyOrders);
    on<GetMySalesEvent>(_onGetMySales);
    on<GetOrderDetailsEvent>(_onGetOrderDetails);
    on<CreateOrderEvent>(_onCreateOrder);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<ConfirmDeliveryEvent>(_onConfirmDelivery);
    on<AcceptOrderEvent>(_onAcceptOrder);
    on<ReportOrderIssueEvent>(_onReportOrderIssue);
    on<InitPaymentEvent>(_onInitPayment);
    on<VerifyManualPaymentEvent>(_onVerifyManualPayment);

    // Listen to real-time updates
    _socketSubscription = socketService.messageStream.listen((data) {
      final event = data['socket_event'];
      if (event == 'order_update' || event == 'payment_status') {
        final orderId = data['orderId'];
        if (orderId != null) {
           add(GetOrderDetailsEvent(orderId: orderId));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }
  Future<void> _onGetMyOrders(
    GetMyOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    // Only show loading if we don't have data yet
    if (state is! OrdersLoaded) {
      emit(OrderLoading());
    }
    
    final result = await orderRepository.getBuyingOrders();
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  Future<void> _onGetMySales(
    GetMySalesEvent event,
    Emitter<OrderState> emit,
  ) async {
    // Only show loading if we don't have data yet
    if (state is! SalesLoaded) {
      emit(OrderLoading());
    }

    final result = await orderRepository.getSellingOrders();
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (sales) => emit(SalesLoaded(sales)),
    );
  }

  Future<void> _onGetOrderDetails(
    GetOrderDetailsEvent event,
    Emitter<OrderState> emit,
  ) async {
    // Only show loading if we are not already showing details for this specific order
    final isShowingSameOrder = state is OrderDetailsLoaded && (state as OrderDetailsLoaded).order.id == event.orderId;
    
    if (!isShowingSameOrder) {
      emit(OrderLoading());
    }

    final result = await orderRepository.getOrderDetails(event.orderId);
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderDetailsLoaded(order)),
    );
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoading) return;
    emit(OrderLoading());
    
    final result = await orderRepository.createOrder(
      productId: event.productId,
      deliveryMethod: event.deliveryMethod,
    );

    await result.fold(
      (failure) async => emit(OrderError(failure.message)),
      (order) async {
        // Emit created but keep loading state conceptually for the next step
        emit(OrderCreated(order));
        
        // Auto-initialize payment - don't emit OrderLoading again as it's already in a transition state
        final paymentResult = await orderRepository.initPayment(order.id);
        paymentResult.fold(
          (failure) => emit(OrderError(failure.message)),
          (data) => emit(PaymentInitialized(data['checkout_url']!, order.id, data['tx_ref']!)),
        );
      },
    );
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderRepository.updateOrderStatus(
      orderId: event.orderId,
      status: event.status,
      trackingNumber: event.trackingNumber,
      courierName: event.courierName,
    );
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderStatusUpdated(order)),
    );
  }

  Future<void> _onConfirmDelivery(
    ConfirmDeliveryEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderRepository.confirmDelivery(
      orderId: event.orderId,
      scannedToken: event.scannedToken,
    );
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderStatusUpdated(order)),
    );
  }

  Future<void> _onAcceptOrder(
    AcceptOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderRepository.acceptOrder(event.orderId);
    await result.fold(
      (failure) async => emit(OrderError(failure.message)),
      (_) async {
        final detailsResult = await orderRepository.getOrderDetails(event.orderId);
        detailsResult.fold(
          (failure) => emit(OrderError(failure.message)),
          (order) => emit(OrderStatusUpdated(order)),
        );
      },
    );
  }

  Future<void> _onReportOrderIssue(
    ReportOrderIssueEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderRepository.reportOrderIssue(event.orderId, event.reason);
    await result.fold(
      (failure) async => emit(OrderError(failure.message)),
      (_) async {
        final detailsResult = await orderRepository.getOrderDetails(event.orderId);
        detailsResult.fold(
          (failure) => emit(OrderError(failure.message)),
          (order) => emit(OrderStatusUpdated(order)),
        );
      },
    );
  }

  Future<void> _onInitPayment(
    InitPaymentEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrderLoading) return;
    emit(OrderLoading());
    final result = await orderRepository.initPayment(event.orderId);
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (data) => emit(PaymentInitialized(data['checkout_url']!, event.orderId, data['tx_ref']!)),
    );
  }

  Future<void> _onVerifyManualPayment(
    VerifyManualPaymentEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderRepository.verifyManualPayment(event.txRef);
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderStatusUpdated(order)),
    );
  }
}
