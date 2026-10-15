import 'package:flutter/material.dart';

/// Bảng mã màu chuẩn của hệ thống Design System (Coffee & Food Ordering App)
class AppColors {
  AppColors._();

  // 1. Core Brand Colors (Yêu cầu chính)
  /// Màu chủ đạo: Nâu cam cà phê ấm (#C67C4E)
  static const Color primary = Color(0xFFC67C4E);

  /// Màu phụ / Điểm nhấn: Be sữa mềm mại (#EDD6C8)
  static const Color secondary = Color(0xFFEDD6C8);
  static const Color accent = secondary;

  /// Màu nền chính ứng dụng: Trắng xám nhạt hiện đại (#F9F9F9)
  static const Color background = Color(0xFFF9F9F9);

  /// Màu chữ chính (Đậm): Xám đen thanh lịch (#313131)
  static const Color textPrimary = Color(0xFF313131);

  /// Màu viền / Nền sáng phụ trợ (#E3E3E3)
  static const Color lightBorder = Color(0xFFE3E3E3);
  static const Color border = lightBorder;

  // 2. Secondary & Supporting UI Colors
  /// Màu chữ phụ (Mô tả, nhãn phụ, placeholder)
  static const Color textSecondary = Color(0xFF989898);

  /// Màu chữ nhạt / Disable text
  static const Color textLight = Color(0xFFA2A2A2);

  /// Nền bề mặt Card, Modal, Sheet (Trắng tinh khiết)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = surface;

  /// Màu tối (Header banner, Dark mode accents)
  static const Color darkBackground = Color(0xFF222222);
  static const Color darkCard = Color(0xFF313131);

  /// Màu sao đánh giá (Rating gold)
  static const Color rating = Color(0xFFFBBE21);

  /// Màu thông báo thành công (Success)
  static const Color success = Color(0xFF2E7D32);

  /// Màu cảnh báo / Lỗi (Error)
  static const Color error = Color(0xFFD32F2F);

  /// Màu Divider nhẹ nhàng
  static const Color divider = Color(0xFFF0F0F0);

  /// Hiệu ứng bóng mờ (Card Shadow)
  static BoxShadow cardShadow = BoxShadow(
    color: const Color(0xFF313131).withValues(alpha: 0.06),
    blurRadius: 14,
    offset: const Offset(0, 4),
  );
}
