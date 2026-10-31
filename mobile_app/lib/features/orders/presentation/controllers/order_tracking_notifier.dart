import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/data/models/order_models.dart';
import '../../../cart/data/repositories/order_repository.dart';
import '../../data/models/order_tracking_model.dart';

class OrderTrackingState {
  final List<TrackedOrder> orders;
  final bool isSimulating;
  final int countdownSeconds;

  const OrderTrackingState({
    required this.orders,
    this.isSimulating = false,
    this.countdownSeconds = 0,
  });

  TrackedOrder? get activeOrder =>
      orders.isNotEmpty ? orders.first : null;

  OrderTrackingState copyWith({
    List<TrackedOrder>? orders,
    bool? isSimulating,
    int? countdownSeconds,
  }) {
    return OrderTrackingState(
      orders: orders ?? this.orders,
      isSimulating: isSimulating ?? this.isSimulating,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
    );
  }
}

final orderTrackingNotifierProvider =
    NotifierProvider<OrderTrackingNotifier, OrderTrackingState>(
  OrderTrackingNotifier.new,
);

class OrderTrackingNotifier extends Notifier<OrderTrackingState> {
  Timer? _simulationTimer;
  Timer? _countdownTimer;

  static final List<TrackedOrder> _initialOrders = [
    TrackedOrder(
      orderCode: 'CF82914',
      orderTime: DateTime.now().subtract(const Duration(minutes: 5)),
      branchName: 'Chi Nhánh Quận 1 - Nguyễn Huệ',
      deliveryAddress: '123 Hai Bà Trưng, P. Bến Nghé, Quận 1, TP.HCM',
      items: const [
        OrderItemSummary(
          name: 'Cà Phê Sữa Đá Sài Gòn',
          quantity: 2,
          price: 58000,
        ),
        OrderItemSummary(
          name: 'Bánh Sừng Trâu Bơ Pháp (Croissant)',
          quantity: 1,
          price: 35000,
        ),
      ],
      totalAmount: 108000, // gồm phí ship 15k
      currentStep: OrderStep.received,
      estimatedDeliveryTime: '15 - 20 phút',
      paymentMethodTitle: 'Chuyển khoản VietQR',
    ),
    TrackedOrder(
      orderCode: 'CF65412',
      orderTime: DateTime.now().subtract(const Duration(hours: 3)),
      branchName: 'Chi Nhánh Quận 3 - Hồ Con Rùa',
      deliveryAddress: '42 Trần Cao Vân, P.6, Quận 3, TP.HCM',
      items: const [
        OrderItemSummary(
          name: 'Trà Đào Cam Sả Tươi',
          quantity: 1,
          price: 42000,
        ),
      ],
      totalAmount: 57000,
      currentStep: OrderStep.completed,
      estimatedDeliveryTime: 'Đã giao',
      paymentMethodTitle: 'Tiền mặt (COD)',
      driverName: 'Nguyễn Gia Sinh',
      driverPhone: '0909564613',
      paymentStatus: 'Paid',
    ),
  ];

  @override
  OrderTrackingState build() {
    ref.onDispose(() {
      _simulationTimer?.cancel();
      _countdownTimer?.cancel();
    });

    // TRIỆT TIÊU HOÀN TOÀN: Không bật bất kỳ timer tự động nhảy bước nào
    return const OrderTrackingState(
      orders: [],
      isSimulating: false,
      countdownSeconds: 0,
    ).copyWith(orders: _initialOrders);
  }

  /// Thêm đơn hàng vừa đặt từ Checkout lên đầu danh sách theo dõi
  void addNewOrder(OrderResult result) {
    final newTrackedOrder = TrackedOrder(
      orderCode: result.orderCode,
      orderTime: result.createdAt,
      branchName: result.branchName,
      deliveryAddress: result.shippingAddress,
      items: result.items.isNotEmpty
          ? result.items
              .map((ci) => OrderItemSummary(
                    name: '${ci.product.name}${ci.selectedSize.isNotEmpty ? ' (${ci.selectedSize})' : ''}',
                    quantity: ci.quantity,
                    price: ci.lineTotal,
                  ))
              .toList()
          : [
              OrderItemSummary(
                name: 'Đơn hàng Coffee & Food',
                quantity: result.totalQuantity,
                price: result.totalAmount,
              ),
            ],
      totalAmount: result.totalAmount,
      currentStep: OrderStep.received,
      estimatedDeliveryTime: '15 - 20 phút',
      paymentMethodTitle: result.paymentMethodTitle,
      driverName: result.driverName,
      driverPhone: result.driverPhone,
      paymentStatus: result.paymentStatus,
    );

    // Không tự động mô phỏng - Đơn hàng giữ nguyên trạng thái "Đã nhận đơn" cho đến khi Admin duyệt
    state = state.copyWith(
      orders: [newTrackedOrder, ...state.orders],
      isSimulating: false,
      countdownSeconds: 0,
    );
  }

  /// Vô hiệu hóa chế độ giả lập tự động - Trạng thái đơn CHỈ thay đổi khi Admin bấm nút thủ công
  void startSimulation() {
    _simulationTimer?.cancel();
    _countdownTimer?.cancel();
    state = state.copyWith(isSimulating: false, countdownSeconds: 0);
  }

  void pauseSimulation() {
    _simulationTimer?.cancel();
    _countdownTimer?.cancel();
    state = state.copyWith(isSimulating: false, countdownSeconds: 0);
  }

  void toggleSimulation() {
    // Không làm gì - Đã tắt hoàn toàn tính năng tự động nhảy bước
    debugPrint('>> Auto-simulation has been disabled per business rules.');
  }

  static TrackedOrder _applyStepBusinessRules(TrackedOrder order, OrderStep step) {
    String? nextDriverName = order.driverName;
    String? nextDriverPhone = order.driverPhone;
    String nextPaymentStatus = order.paymentStatus;

    if (step == OrderStep.delivering) {
      nextDriverName = (nextDriverName != null && nextDriverName.isNotEmpty)
          ? nextDriverName
          : 'Nguyễn Gia Sinh';
      nextDriverPhone = (nextDriverPhone != null && nextDriverPhone.isNotEmpty)
          ? nextDriverPhone
          : '0909564613';
    } else if (step == OrderStep.completed) {
      nextDriverName = (nextDriverName != null && nextDriverName.isNotEmpty)
          ? nextDriverName
          : 'Nguyễn Gia Sinh';
      nextDriverPhone = (nextDriverPhone != null && nextDriverPhone.isNotEmpty)
          ? nextDriverPhone
          : '0909564613';
      nextPaymentStatus = 'Paid';
    }

    return order.copyWith(
      currentStep: step,
      driverName: nextDriverName,
      driverPhone: nextDriverPhone,
      paymentStatus: nextPaymentStatus,
    );
  }

  /// Chuyển tiến độ thủ công sang bước kế tiếp (khi Admin/người dùng thao tác thủ công)
  void advanceStep() {
    if (state.orders.isEmpty) return;

    final active = state.orders.first;
    final currentIndex = active.currentStep.index;

    final nextIndex = (currentIndex + 1) % OrderStep.values.length;
    final nextStep = OrderStep.values[nextIndex];

    final updatedActive = _applyStepBusinessRules(active, nextStep);
    final updatedList = [updatedActive, ...state.orders.sublist(1)];

    state = state.copyWith(
      orders: updatedList,
      isSimulating: false,
      countdownSeconds: 0,
    );
  }

  /// Đặt trực tiếp một bước cụ thể
  void setStep(OrderStep step) {
    if (state.orders.isEmpty) return;
    final active = _applyStepBusinessRules(state.orders.first, step);
    final updatedList = [active, ...state.orders.sublist(1)];
    state = state.copyWith(orders: updatedList);
  }

  /// Cập nhật trạng thái cho một đơn hàng cụ thể theo mã đơn (UI State)
  void updateOrderStep(String orderCode, OrderStep step) {
    final index = state.orders.indexWhere((o) => o.orderCode == orderCode);
    if (index == -1) return;

    final updated = _applyStepBusinessRules(state.orders[index], step);
    final list = List<TrackedOrder>.from(state.orders);
    list[index] = updated;
    state = state.copyWith(orders: list);
  }

  /// THAO TÁC ADMIN THỰC CHIẾN: Cập nhật trạng thái trên UI đồng thời gọi API xuống Backend C#
  Future<bool> updateOrderStepWithApi(
    String orderCode,
    OrderStep step, {
    required OrderRepository repository,
  }) async {
    // 1. Cập nhật State UI Khách hàng & Admin ngay lập tức để đồng bộ tức thì
    updateOrderStep(orderCode, step);

    // 2. Chuyển đổi sang Status chuẩn của ASP.NET Core API
    final backendStatus = _mapStepToBackendStatus(step);

    // 3. Trích xuất ID số từ mã đơn (ví dụ: 'CF1' -> 1)
    final numericPart = orderCode.replaceAll(RegExp(r'[^0-9]'), '');
    final orderId = int.tryParse(numericPart);

    if (orderId != null && orderId > 0) {
      debugPrint('>> [OrderTrackingNotifier] Gọi API PUT /api/orders/$orderId/status: $backendStatus');
      if (repository is ApiOrderRepository) {
        final dto = await repository.updateOrderStatusAndGetDto(orderId, backendStatus);
        if (dto != null) {
          final index = state.orders.indexWhere((o) => o.orderCode == orderCode);
          if (index != -1 && dto.isNotEmpty) {
            final current = state.orders[index];
            final synced = current.copyWith(
              driverName: (dto['driverName'] as String?) ?? current.driverName,
              driverPhone: (dto['driverPhone'] as String?) ?? current.driverPhone,
              paymentStatus: (dto['paymentStatus'] as String?) ?? current.paymentStatus,
            );
            final list = List<TrackedOrder>.from(state.orders);
            list[index] = synced;
            state = state.copyWith(orders: list);
          }
          return true;
        }
        return false;
      }
      return await repository.updateOrderStatus(orderId, backendStatus);
    }
    return true;
  }

  /// THAO TÁC ADMIN: Từ chối/Hủy đơn hàng có gọi API đồng bộ Backend C#
  Future<bool> rejectOrderWithApi(
    String orderCode, {
    required OrderRepository repository,
  }) async {
    final list = state.orders.where((o) => o.orderCode != orderCode).toList();
    state = state.copyWith(orders: list);

    final numericPart = orderCode.replaceAll(RegExp(r'[^0-9]'), '');
    final orderId = int.tryParse(numericPart);
    if (orderId != null && orderId > 0) {
      debugPrint('>> [OrderTrackingNotifier] Gọi API PUT /api/orders/$orderId/status: Cancelled');
      return await repository.updateOrderStatus(orderId, 'Cancelled');
    }
    return true;
  }

  static String _mapStepToBackendStatus(OrderStep step) {
    switch (step) {
      case OrderStep.received:
        return 'Confirmed';
      case OrderStep.preparing:
        return 'Preparing';
      case OrderStep.delivering:
        return 'Delivering';
      case OrderStep.completed:
        return 'Completed';
    }
  }

  /// Thêm đơn hàng giả lập đang chờ xử lý mới (Dùng demo thuyết trình cho Admin)
  void addMockPendingOrder() {
    final randId = 10000 + DateTime.now().millisecondsSinceEpoch % 90000;
    final newOrder = TrackedOrder(
      orderCode: 'CF$randId',
      orderTime: DateTime.now(),
      branchName: 'Chi Nhánh Quận 1 - Nguyễn Huệ',
      deliveryAddress: '24 Lê Lợi, Bến Nghé, Quận 1, TP.HCM',
      customerName: 'Trần Thị Mỹ Linh',
      customerPhone: '0938 889 999',
      items: const [
        OrderItemSummary(
          name: 'Trà Đào Cam Sả Tươi (Size L)',
          quantity: 2,
          price: 90000,
        ),
        OrderItemSummary(
          name: 'Bánh Mì Chảo Đặc Biệt',
          quantity: 1,
          price: 45000,
        ),
      ],
      totalAmount: 150000,
      currentStep: OrderStep.received,
      estimatedDeliveryTime: '20 - 25 phút',
      paymentMethodTitle: 'Chuyển khoản VietQR',
    );

    state = state.copyWith(orders: [newOrder, ...state.orders]);
  }
}
