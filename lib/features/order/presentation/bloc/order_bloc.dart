import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    on<GetMyOrdersEvent>(_onGetMyOrders);
    on<GetMySalesEvent>(_onGetMySales);
    on<GetOrderDetailsEvent>(_onGetOrderDetails);
    on<CreateOrderEvent>(_onCreateOrder);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<ConfirmDeliveryEvent>(_onConfirmDelivery);
    on<AcceptOrderEvent>(_onAcceptOrder);
    on<ReportOrderIssueEvent>(_onReportOrderIssue);
  }


  Future<void> _onGetMyOrders(
    GetMyOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
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
    emit(OrderLoading());
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
    emit(OrderLoading());
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
    emit(OrderLoading());
    final result = await orderRepository.createOrder(
      productId: event.productId,
      deliveryMethod: event.deliveryMethod,
    );
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderCreated(order)),
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
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (_) => add(GetOrderDetailsEvent(orderId: event.orderId)),
    );
  }

  Future<void> _onReportOrderIssue(
    ReportOrderIssueEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderRepository.reportOrderIssue(event.orderId, event.reason);
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (_) => add(GetOrderDetailsEvent(orderId: event.orderId)),
    );
  }
}
