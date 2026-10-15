import 'package:flutter/material.dart';

/// Hằng số kích thước chuẩn trong toàn bộ ứng dụng (Spacings, Radius, Heights)
class AppDimens {
  AppDimens._();

  // Spacings
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;

  // BorderRadius
  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r10 = 10.0;
  static const double r12 = 12.0;
  static const double r14 = 14.0;
  static const double r16 = 16.0; // Chuẩn theo thiết kế cho Buttons & Cards
  static const double r18 = 18.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double rFull = 999.0;

  // Button Heights
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 44.0;

  // Icon Sizes
  static const double iconSmall = 18.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  // Screen horizontal padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 24.0);
}
