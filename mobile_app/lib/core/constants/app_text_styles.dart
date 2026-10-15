import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Hệ thống kiểu chữ (Typography) chuẩn sử dụng Font chữ 'Sora'
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Sora';

  // ---------------------------------------------------------------------------
  // HEADING STYLES (Tiêu đề, Bold / SemiBold, Màu #313131)
  // ---------------------------------------------------------------------------

  /// Tiêu đề cực lớn (Hero / Splash / Title chính) - 34sp Bold
  static TextStyle get h1 => GoogleFonts.sora(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
        letterSpacing: -0.5,
      );

  /// Tiêu đề lớn (Section Title / Screen Title) - 24sp Bold
  static TextStyle get h2 => GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: -0.3,
      );

  /// Tiêu đề vừa (Card Title / Dialog Title) - 18sp Bold
  static TextStyle get h3 => GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  /// Tiêu đề nhỏ (Subtitle / Section Header nhỏ) - 16sp SemiBold
  static TextStyle get subtitle => GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ---------------------------------------------------------------------------
  // BODY STYLES (Nội dung văn bản, Regular / Medium, Màu #313131 hoặc textSecondary)
  // ---------------------------------------------------------------------------

  /// Văn bản lớn (16sp Regular)
  static TextStyle get bodyLarge => GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// Văn bản tiêu chuẩn (14sp Regular - Mặc định cho Body)
  static TextStyle get bodyMedium => GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// Văn bản mô tả phụ (14sp Regular, màu TextSecondary #989898)
  static TextStyle get bodyMediumSecondary => GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  /// Văn bản nhỏ (12sp Regular)
  static TextStyle get bodySmall => GoogleFonts.sora(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ---------------------------------------------------------------------------
  // COMPONENT STYLES (Button, Caption, Tag, Price)
  // ---------------------------------------------------------------------------

  /// Chữ trên nút bấm (16sp SemiBold, màu trắng)
  static TextStyle get button => GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  /// Giá tiền (18sp SemiBold, màu Primary #C67C4E)
  static TextStyle get price => GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: -0.2,
      );

  /// Chú thích / Nhãn nhỏ (10sp Medium)
  static TextStyle get caption => GoogleFonts.sora(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );
}
