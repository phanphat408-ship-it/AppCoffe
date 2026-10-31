import 'package:flutter/material.dart';

/// Các phương thức thanh toán hỗ trợ trong ứng dụng
enum PaymentMethod {
  cash(
    id: 'cash',
    title: 'Tiền mặt (COD)',
    subtitle: 'Thanh toán trực tiếp khi nhận hàng',
    icon: Icons.payments_rounded,
    badgeColor: Color(0xFF2E7D32),
  ),
  vietqr(
    id: 'vietqr',
    title: 'Chuyển khoản VietQR',
    subtitle: 'Quét mã QR qua mọi ứng dụng ngân hàng',
    icon: Icons.qr_code_2_rounded,
    badgeColor: Color(0xFFC67C4E),
    isRecommended: true,
  ),
  momo(
    id: 'momo',
    title: 'Ví MoMo',
    subtitle: 'Thanh toán tức thì qua ví điện tử MoMo',
    icon: Icons.account_balance_wallet_rounded,
    badgeColor: Color(0xFFA50064),
  ),
  zalopay(
    id: 'zalopay',
    title: 'Ví ZaloPay',
    subtitle: 'Giảm thêm khi liên kết ví ZaloPay',
    icon: Icons.wallet_rounded,
    badgeColor: Color(0xFF0068FF),
  ),
  vnpay(
    id: 'vnpay',
    title: 'Cổng VNPAY-QR',
    subtitle: 'Thanh toán thẻ ATM nội địa & Quốc tế',
    icon: Icons.credit_card_rounded,
    badgeColor: Color(0xFFED1C24),
  );

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color badgeColor;
  final bool isRecommended;

  const PaymentMethod({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badgeColor,
    this.isRecommended = false,
  });
}

/// Model Voucher khuyến mãi
class VoucherModel {
  final String code;
  final String title;
  final String description;
  final int discountAmount;
  final bool isFreeship;
  final int minOrderAmount;
  final String expiryDate;

  const VoucherModel({
    required this.code,
    required this.title,
    required this.description,
    required this.discountAmount,
    this.isFreeship = false,
    this.minOrderAmount = 0,
    this.expiryDate = '31/12/2026',
  });

  static const List<VoucherModel> availableVouchers = [
    VoucherModel(
      code: 'FREESHIP',
      title: 'Miễn phí giao hàng',
      description: 'Giảm tối đa 15.000đ phí giao hàng toàn quốc',
      discountAmount: 15000,
      isFreeship: true,
      minOrderAmount: 0,
    ),
    VoucherModel(
      code: 'COFFEE10',
      title: 'Giảm 10.000đ',
      description: 'Áp dụng cho đơn hàng từ 40.000đ',
      discountAmount: 10000,
      minOrderAmount: 40000,
    ),
    VoucherModel(
      code: 'VIP20',
      title: 'Giảm 20.000đ Khách VIP',
      description: 'Áp dụng cho đơn hàng từ 80.000đ',
      discountAmount: 20000,
      minOrderAmount: 80000,
    ),
    VoucherModel(
      code: 'BANMOI',
      title: 'Chào bạn mới Giảm 15k',
      description: 'Áp dụng cho đơn hàng đầu tiên từ 50.000đ',
      discountAmount: 15000,
      minOrderAmount: 50000,
    ),
  ];
}

/// Model Tài xế giao hàng mô phỏng (Grab / Be / Xanh SM)
class DriverInfo {
  final String name;
  final String phone;
  final String licensePlate;
  final String vehicleModel;
  final String serviceBrand; // Xanh SM Bike, GrabBike, BeFood
  final Color brandColor;
  final double rating;
  final int totalTrips;
  final String avatarUrl;

  const DriverInfo({
    required this.name,
    required this.phone,
    required this.licensePlate,
    required this.vehicleModel,
    required this.serviceBrand,
    required this.brandColor,
    required this.rating,
    required this.totalTrips,
    required this.avatarUrl,
  });

  static const DriverInfo defaultDriver = DriverInfo(
    name: 'Nguyễn Gia Sinh',
    phone: '0909564613',
    licensePlate: '59-X3 888.68',
    vehicleModel: 'VinFast Feliz S (Xanh Lục Bảo)',
    serviceBrand: 'Xanh SM Bike 🛵',
    brandColor: Color(0xFF00A651),
    rating: 4.9,
    totalTrips: 1420,
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
  );

  DriverInfo copyWith({
    String? name,
    String? phone,
    String? licensePlate,
    String? vehicleModel,
    String? serviceBrand,
    Color? brandColor,
    double? rating,
    int? totalTrips,
    String? avatarUrl,
  }) {
    return DriverInfo(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      serviceBrand: serviceBrand ?? this.serviceBrand,
      brandColor: brandColor ?? this.brandColor,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
