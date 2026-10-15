import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/data/models/order_models.dart';
import '../../data/models/order_tracking_model.dart';

class OrderTrackingState {
  final List<TrackedOrder> orders;
  final bool isSimulating;
  final int countdownSeconds;

  const OrderTrackingState({
    required this.orders,
    this.isSimulating = true,
    this.countdownSeconds = 6,
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
    ),
  ];

  @override
  OrderTrackingState build() {
    var isDisposed = false;
    ref.onDispose(() {
      isDisposed = true;
      _simulationTimer?.cancel();
      _countdownTimer?.cancel();
    });

    // Tự động bật chế độ Demo mô phỏng (Hiệu ứng siêu ứng dụng)
    Future.microtask(() {
      if (!isDisposed) {
        startSimulation();
      }
    });

    return OrderTrackingState(orders: _initialOrders);
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
    );

    state = state.copyWith(
      orders: [newTrackedOrder, ...state.orders],
      countdownSeconds: 6,
    );
    startSimulation();
  }

  /// Bắt đầu giả lập tự động nhảy bước trạng thái sau mỗi 6 giây
  void startSimulation() {
    _simulationTimer?.cancel();
    _countdownTimer?.cancel();

    state = state.copyWith(isSimulating: true, countdownSeconds: 6);

    // Đếm ngược từng giây hiển thị trên UI
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownSeconds <= 1) {
        state = state.copyWith(countdownSeconds: 6);
      } else {
        state = state.copyWith(countdownSeconds: state.countdownSeconds - 1);
      }
    });

    // Cứ sau 6 giây tự động nhảy bước tuần tự
    _simulationTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      advanceStep();
    });
  }

  /// Tạm dừng hiệu ứng tự động
  void pauseSimulation() {
    _simulationTimer?.cancel();
    _countdownTimer?.cancel();
    state = state.copyWith(isSimulating: false);
  }

  /// Bật/tắt chế độ tự động nhảy bước
  void toggleSimulation() {
    if (state.isSimulating) {
      pauseSimulation();
    } else {
      startSimulation();
    }
  }

  /// Chuyển tiến độ đơn hàng sang bước kế tiếp:
  /// Đã nhận đơn -> Quán đang pha chế -> Tài xế đang giao -> Hoàn tất
  void advanceStep() {
    if (state.orders.isEmpty) return;

    final active = state.orders.first;
    final currentIndex = active.currentStep.index;

    // Chu kỳ 4 bước: 0 -> 1 -> 2 -> 3 -> 0
    final nextIndex = (currentIndex + 1) % OrderStep.values.length;
    final nextStep = OrderStep.values[nextIndex];

    final updatedActive = active.copyWith(currentStep: nextStep);
    final updatedList = [updatedActive, ...state.orders.sublist(1)];

    state = state.copyWith(
      orders: updatedList,
      countdownSeconds: 6,
    );
  }

  /// Đặt trực tiếp một bước cụ thể
  void setStep(OrderStep step) {
    if (state.orders.isEmpty) return;
    final active = state.orders.first.copyWith(currentStep: step);
    final updatedList = [active, ...state.orders.sublist(1)];
    state = state.copyWith(orders: updatedList);
  }

  /// Cập nhật trạng thái cho một đơn hàng cụ thể theo mã đơn (Quản trị viên duyệt đơn)
  void updateOrderStep(String orderCode, OrderStep step) {
    final index = state.orders.indexWhere((o) => o.orderCode == orderCode);
    if (index == -1) return;

    final updated = state.orders[index].copyWith(currentStep: step);
    final list = List<TrackedOrder>.from(state.orders);
    list[index] = updated;
    state = state.copyWith(orders: list);
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
