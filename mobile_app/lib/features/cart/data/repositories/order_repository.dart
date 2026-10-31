import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_models.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiOrderRepository(dio);
});

/// Hợp đồng (contract) cho tầng gửi và cập nhật đơn hàng.
abstract class OrderRepository {
  Future<OrderResult> submitOrder(OrderRequest request);
  Future<bool> updateOrderStatus(int orderId, String status);
}

/// Tầng giao tiếp mạng thực tế gọi HTTP POST `/api/orders` tới ASP.NET Core API
class ApiOrderRepository implements OrderRepository {
  final Dio _dio;

  ApiOrderRepository(this._dio);

  @override
  Future<OrderResult> submitOrder(OrderRequest request) async {
    final payload = request.toJson();
    debugPrint('>> [ApiOrderRepository] Gửi POST ${ApiEndpoints.orders}: $payload');

    try {
      final response = await _dio.post(
        ApiEndpoints.orders,
        data: payload,
      );

      // Bắt buộc kiểm tra statusCode của HTTP response (200 hoặc 201 Created)
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw OrderException(
          'Đặt hàng thất bại. Máy chủ trả về mã HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final success = data['success'] as bool? ?? false;
        if (!success) {
          final message = data['message'] as String? ?? 'Đặt hàng thất bại từ máy chủ.';
          throw OrderException(message);
        }

        final orderData = data['data'] as Map<String, dynamic>?;
        final orderId = orderData?['id'] as int? ?? 0;
        final createdAtStr = orderData?['createdAt'] as String?;
        final createdAt = createdAtStr != null
            ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
            : DateTime.now();

        return OrderResult(
          orderCode: 'CF$orderId',
          totalAmount: (orderData?['totalAmount'] as num?)?.toInt() ?? request.total,
          totalQuantity: request.totalQuantity,
          createdAt: createdAt,
          branchName: request.branchName ?? (orderData?['branchName'] as String?) ?? 'Chi Nhánh Quán Cà Phê',
          shippingAddress: request.shippingAddress ?? (orderData?['shippingAddress'] as String?) ?? '',
          paymentMethodTitle: request.paymentMethod.title,
          items: request.items,
          driverName: orderData?['driverName'] as String?,
          driverPhone: orderData?['driverPhone'] as String?,
          paymentStatus: (orderData?['paymentStatus'] as String?) ?? 'Pending',
        );
      }

      throw const OrderException('Phản hồi từ máy chủ không đúng định dạng JSON.');
    } on DioException catch (e) {
      debugPrint('>> [ApiOrderRepository] DioException: ${e.message}, response: ${e.response?.data}');
      final response = e.response;
      if (response != null) {
        final resData = response.data;
        if (resData is Map<String, dynamic> && resData['message'] != null) {
          throw OrderException(resData['message'].toString());
        }
        throw OrderException(
          'Máy chủ từ chối yêu cầu (HTTP ${response.statusCode}): ${response.statusMessage ?? "Lỗi xử lý đơn hàng"}',
        );
      }
      throw OrderException(
        'Không thể kết nối đến máy chủ API (${ApiEndpoints.baseUrl}). Vui lòng kiểm tra Backend C# đang chạy.',
      );
    }
  }

  /// Cập nhật trạng thái đơn hàng và trả về JSON `OrderDto` mới nhất từ Backend (gồm `driverName`, `driverPhone`, `paymentStatus`)
  Future<Map<String, dynamic>?> updateOrderStatusAndGetDto(int orderId, String status) async {
    final endpoint = '${ApiEndpoints.orders}/$orderId/status';
    debugPrint('>> [ApiOrderRepository] Gửi PUT $endpoint với status="$status"');
    try {
      final response = await _dio.put(
        endpoint,
        data: {'status': status},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('>> [ApiOrderRepository] Cập nhật đơn #$orderId thành "$status" thành công (HTTP ${response.statusCode})');
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return (data['data'] as Map<String, dynamic>?) ?? data;
        }
        return <String, dynamic>{};
      }
      return null;
    } on DioException catch (e) {
      debugPrint('>> [ApiOrderRepository] DioException khi PUT status: ${e.message}, response: ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('>> [ApiOrderRepository] Ngoại lệ khi cập nhật trạng thái đơn: $e');
      return null;
    }
  }

  @override
  Future<bool> updateOrderStatus(int orderId, String status) async {
    final dto = await updateOrderStatusAndGetDto(orderId, status);
    return dto != null;
  }
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

  @override
  Future<bool> updateOrderStatus(int orderId, String status) async {
    debugPrint('>> [MockOrderRepository] updateOrderStatus: orderId=$orderId, status=$status');
    return true;
  }
}

/// Lỗi nghiệp vụ khi đặt hàng
class OrderException implements Exception {
  final String message;
  const OrderException(this.message);

  @override
  String toString() => message;
}
