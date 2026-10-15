import 'cart_item.dart';
import 'checkout_models.dart';

/// Hình thức nhận hàng – khớp giá trị chuỗi với Backend (`DeliveryType`)
enum DeliveryType {
  delivery('Delivery', 'Giao tận nơi 🛵'),
  takeaway('Takeaway', 'Tự đến lấy tại quán 🛍️'),
  dineIn('DineIn', 'Dùng tại quán ☕');

  final String apiValue;
  final String label;
  const DeliveryType(this.apiValue, this.label);
}

/// Payload gửi lên khi đặt hàng.
/// Cấu trúc `toJson()` khớp với `CreateOrderDto` của ASP.NET Core API.
class OrderRequest {
  final List<CartItem> items;
  final int subtotal;
  final int deliveryFee;
  final int discount;
  final int total;
  final String? note;
  final DeliveryType deliveryType;
  final int? branchId;
  final String? branchName;
  final String? shippingAddress;
  final String? contactPhone;
  final PaymentMethod paymentMethod;
  final String? voucherCode;

  const OrderRequest({
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    required this.total,
    this.note,
    this.deliveryType = DeliveryType.delivery,
    this.branchId,
    this.branchName,
    this.shippingAddress,
    this.contactPhone,
    this.paymentMethod = PaymentMethod.cash,
    this.voucherCode,
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() {
    return {
      'deliveryType': deliveryType.apiValue,
      if (branchId != null) 'branchId': branchId,
      if (shippingAddress != null) 'shippingAddress': shippingAddress,
      if (contactPhone != null) 'contactPhone': contactPhone,
      'note': _buildFullNote(),
      'items': items
          .map((item) => {
                'productId': item.productId,
                'quantity': item.quantity,
              })
          .toList(),
    };
  }

  String _buildFullNote() {
    final parts = <String>[];
    parts.add('[PT: ${paymentMethod.title}]');
    if (voucherCode != null && voucherCode!.isNotEmpty) {
      parts.add('[Voucher: $voucherCode (-$discount đ)]');
    }
    if (note != null && note!.trim().isNotEmpty) {
      parts.add(note!.trim());
    }
    return parts.join(' - ');
  }
}

/// Kết quả trả về sau khi đặt hàng thành công
class OrderResult {
  final String orderCode;
  final int totalAmount;
  final int totalQuantity;
  final DateTime createdAt;
  final Duration estimatedTime;
  final String branchName;
  final String shippingAddress;
  final String paymentMethodTitle;
  final List<CartItem> items;

  const OrderResult({
    required this.orderCode,
    required this.totalAmount,
    required this.totalQuantity,
    required this.createdAt,
    this.estimatedTime = const Duration(minutes: 20),
    this.branchName = 'Chi Nhánh Nguyễn Huệ - Quận 1',
    this.shippingAddress = '123 Hai Bà Trưng, P. Bến Nghé, Quận 1, TP.HCM',
    this.paymentMethodTitle = 'Tiền mặt (COD)',
    this.items = const [],
  });
}
