import 'package:flutter/material.dart';

/// Model banner khuyến mãi
class BannerModel {
  final int id;
  final String tag;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final IconData? icon;
  final Color startColor;
  final Color endColor;

  const BannerModel({
    required this.id,
    required this.tag,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.icon,
    required this.startColor,
    required this.endColor,
  });
}
