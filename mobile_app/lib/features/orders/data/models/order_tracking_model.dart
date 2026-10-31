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

  final String? driverName;
  final String? driverPhone;
  final String paymentStatus;

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
    this.driverName,
    this.driverPhone,
    this.paymentStatus = 'Pending',
  });

  factory TrackedOrder.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? 0;
    final statusStr = (json['status'] as String? ?? 'Pending').toLowerCase();
    final step = switch (statusStr) {
      'preparing' => OrderStep.preparing,
      'delivering' => OrderStep.delivering,
      'completed' => OrderStep.completed,
      _ => OrderStep.received,
    };
    final dName = json['driverName'] as String?;
    final dPhone = json['driverPhone'] as String?;
    final pStatus = (json['paymentStatus'] as String?) ?? 'Pending';
    final details = (json['orderDetails'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(
          (d) => OrderItemSummary(
            name: (d['productName'] as String?) ?? 'Sản phẩm',
            quantity: (d['quantity'] as num?)?.toInt() ?? 1,
            price: (d['totalPrice'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();

    return TrackedOrder(
      orderCode: 'CF$id',
      orderTime: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      branchName: (json['branchName'] as String?) ?? 'Chi Nhánh Quận 1 - Nguyễn Huệ',
      deliveryAddress: (json['shippingAddress'] as String?) ?? '',
      items: details,
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      currentStep: step,
      estimatedDeliveryTime: step == OrderStep.completed ? 'Đã giao' : '15 - 20 phút',
      driver: DriverInfo.defaultDriver.copyWith(
        name: (dName != null && dName.isNotEmpty) ? dName : null,
        phone: (dPhone != null && dPhone.isNotEmpty) ? dPhone : null,
      ),
      customerName: (json['customerName'] as String?) ?? 'Nguyễn Văn Khách',
      customerPhone: (json['customerPhone'] as String?) ?? '0909 123 456',
      driverName: dName,
      driverPhone: dPhone,
      paymentStatus: pStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderCode': orderCode,
      'orderTime': orderTime.toIso8601String(),
      'branchName': branchName,
      'deliveryAddress': deliveryAddress,
      'totalAmount': totalAmount,
      'status': currentStep.name,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'paymentStatus': paymentStatus,
    };
  }

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
    String? driverName,
    String? driverPhone,
    String? paymentStatus,
  }) {
    final nextDriverName = driverName ?? this.driverName;
    final nextDriverPhone = driverPhone ?? this.driverPhone;
    final baseDriver = driver ?? this.driver;
    final syncedDriver = baseDriver.copyWith(
      name: (nextDriverName != null && nextDriverName.isNotEmpty)
          ? nextDriverName
          : baseDriver.name,
      phone: (nextDriverPhone != null && nextDriverPhone.isNotEmpty)
          ? nextDriverPhone
          : baseDriver.phone,
    );

    return TrackedOrder(
      orderCode: orderCode ?? this.orderCode,
      orderTime: orderTime ?? this.orderTime,
      branchName: branchName ?? this.branchName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      currentStep: currentStep ?? this.currentStep,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      driver: syncedDriver,
      paymentMethodTitle: paymentMethodTitle ?? this.paymentMethodTitle,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      driverName: nextDriverName,
      driverPhone: nextDriverPhone,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}
