import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget hiển thị hình ảnh từ Network an toàn, bọc `Image.network` kỹ càng với:
/// 1. Hiệu ứng Shimmer Skeleton mượt mà khi đang tải (loadingBuilder)
/// 2. Giao diện Fallback cao cấp khi link chết hoặc offline (errorBuilder)
/// Tuyệt đối không để xảy ra khung đỏ lỗi hoặc ô trống trơn.
class AppNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Widget? fallbackWidget;
  final Color? backgroundColor;
  final int? cacheWidth;
  final int? cacheHeight;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.coffee_rounded,
    this.fallbackWidget,
    this.backgroundColor,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.secondary.withValues(alpha: 0.25);
    final cleanUrl = widget.imageUrl.trim();
    final isUrlInvalid = cleanUrl.isEmpty || !cleanUrl.startsWith('http');

    Widget content;

    if (isUrlInvalid) {
      content = _buildFallback(bgColor);
    } else {
      content = Image.network(
        cleanUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: widget.cacheWidth ?? 400,
        cacheHeight: widget.cacheHeight,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _buildShimmer(bgColor);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(bgColor);
        },
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return content;
  }

  /// Khung chờ Shimmer hiệu ứng ánh sáng quét ngang
  Widget _buildShimmer(Color bgColor) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.5 + 3.0 * _shimmerController.value, -0.3),
              end: Alignment(-0.5 + 3.0 * _shimmerController.value, 0.3),
              colors: [
                bgColor,
                Colors.white.withValues(alpha: 0.7),
                bgColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Icon(
              widget.fallbackIcon,
              color: AppColors.primary.withValues(alpha: 0.25),
              size: (widget.height != null && widget.height! < 50) ? 20 : 32,
            ),
          ),
        );
      },
    );
  }

  /// Giao diện Fallback thanh lịch khi hình ảnh bị lỗi
  Widget _buildFallback(Color bgColor) {
    if (widget.fallbackWidget != null) {
      return widget.fallbackWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.fallbackIcon,
                color: AppColors.primary,
                size: (widget.height != null && widget.height! < 60) ? 18 : 28,
              ),
            ),
            if (widget.height == null || widget.height! >= 100) ...[
              const SizedBox(height: 6),
              Text(
                'Coffee & Tea',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
