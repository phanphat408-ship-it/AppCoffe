import '../../../cart/data/models/checkout_models.dart';

/// 4 bước tiến trình trực quan theo thời gian thực (Timeline) chuẩn Grab/Be/Xanh SM
enum OrderStep {
  received(
    title: 'Đã nhận đơn',
    subtitle: 'Quán đã tiếp nhận đơn và in phiếu chế biến',
  ),
  preparing(
    title: 'Quán đang pha chế',
    subtitle: 'Barista đang chuẩn bị đồ uống & đóng gói',
  ),
  delivering(
    title: 'Tài xế đang giao',
    subtitle: 'Tài xế đang di chuyển trên đường giao đến bạn',
  ),
  completed(
    title: 'Hoàn tất',
    subtitle: 'Giao hàng thành công. Chúc bạn ngon miệng!',
  );

  final String title;
  final String subtitle;

  const OrderStep({
    required this.title,
    required this.subtitle,
  });
}

/// Model món trong đơn hàng
class OrderItemSummary {
  final String name;
  final int quantity;
  final int price;

  const OrderItemSummary({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

/// Model đơn hàng theo dõi chuẩn siêu ứng dụng
class TrackedOrder {
  final String orderCode;
  final DateTime orderTime;
  final String branchName;
  final String deliveryAddress;
  final List<OrderItemSummary> items;
  final int totalAmount;
  final OrderStep currentStep;
  final String estimatedDeliveryTime;
  final DriverInfo driver;
  final String paymentMethodTitle;

  final String customerName;
  final String customerPhone;

  const TrackedOrder({
    required this.orderCode,
    required this.orderTime,
    required this.branchName,
    required this.deliveryAddress,
    required this.items,
    required this.totalAmount,
    required this.currentStep,
    required this.estimatedDeliveryTime,
    this.driver = DriverInfo.defaultDriver,
    this.paymentMethodTitle = 'Chuyển khoản VietQR',
    this.customerName = 'Nguyễn Văn Khách',
    this.customerPhone = '0909 123 456',
  });

  TrackedOrder copyWith({
    String? orderCode,
    DateTime? orderTime,
    String? branchName,
    String? deliveryAddress,
    List<OrderItemSummary>? items,
    int? totalAmount,
    OrderStep? currentStep,
    String? estimatedDeliveryTime,
    DriverInfo? driver,
    String? paymentMethodTitle,
    String? customerName,
    String? customerPhone,
  }) {
    return TrackedOrder(
      orderCode: orderCode ?? this.orderCode,
      orderTime: orderTime ?? this.orderTime,
      branchName: branchName ?? this.branchName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      currentStep: currentStep ?? this.currentStep,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      driver: driver ?? this.driver,
      paymentMethodTitle: paymentMethodTitle ?? this.paymentMethodTitle,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }
}
