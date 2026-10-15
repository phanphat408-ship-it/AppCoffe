import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_models.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return MockOrderRepository();
});

/// Hợp đồng (contract) cho tầng gửi đơn hàng.
/// Khi nối API thật chỉ cần tạo `ApiOrderRepository` (dùng Dio POST `/api/orders`)
/// và đổi `orderRepositoryProvider` – UI & Notifier không phải sửa gì.
abstract class OrderRepository {
  Future<OrderResult> submitOrder(OrderRequest request);
}

/// Mock API: giả lập độ trễ mạng và trả về mã đơn hàng.
class MockOrderRepository implements OrderRepository {
  final Duration latency;

  MockOrderRepository({this.latency = const Duration(milliseconds: 1500)});

  @override
  Future<OrderResult> submitOrder(OrderRequest request) async {
    debugPrint('>> [MockOrderRepository] submitOrder payload: ${request.toJson()}');

    await Future<void>.delayed(latency);

    // Kiểm tra phía "server" – phòng thủ thêm một lớp
    if (request.items.isEmpty) {
      throw const OrderException('Đơn hàng không có món nào.');
    }

    final now = DateTime.now();
    final code = 'CF${now.millisecondsSinceEpoch.toString().substring(5)}';

    return OrderResult(
      orderCode: code,
      totalAmount: request.total,
      totalQuantity: request.totalQuantity,
      createdAt: now,
      branchName: request.branchName ?? 'Chi Nhánh Quận 1 - Nguyễn Huệ',
      shippingAddress: request.shippingAddress ?? '123 Hai Bà Trưng, P. Bến Nghé, Quận 1, TP.HCM',
      paymentMethodTitle: request.paymentMethod.title,
      items: request.items,
    );
  }
}

/// Lỗi nghiệp vụ khi đặt hàng
class OrderException implements Exception {
  final String message;
  const OrderException(this.message);

  @override
  String toString() => message;
}
