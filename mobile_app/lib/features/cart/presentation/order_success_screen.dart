import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../data/models/order_models.dart';

/// Màn hình "Đặt hàng thành công".
/// Nút Back của hệ thống được chuyển hướng về Trang chủ (không quay lại giỏ cũ).
class OrderSuccessScreen extends StatelessWidget {
  final OrderResult? result;

  const OrderSuccessScreen({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.p24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      const _AnimatedIllustration(),
                      const SizedBox(height: 28),
                      _FadeSlideIn(
                        delay: const Duration(milliseconds: 250),
                        child: Column(
                          children: [
                            Text(
                              'Đặt hàng thành công!',
                              style: AppTextStyles.h2,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Cảm ơn bạn đã tin chọn quán. Barista đang pha chế '
                              'và đơn hàng sẽ sớm được giao đến bạn ☕',
                              style: AppTextStyles.bodyMediumSecondary,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (result != null) ...[
                        const SizedBox(height: 24),
                        _FadeSlideIn(
                          delay: const Duration(milliseconds: 400),
                          child: _OrderInfoCard(result: result!),
                        ),
                      ],
                      const Spacer(),
                      const SizedBox(height: 24),
                      _FadeSlideIn(
                        delay: const Duration(milliseconds: 550),
                        child: AppButton(
                          title: 'Về trang chủ',
                          icon: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
                          onPressed: () => context.go(AppRoutes.home),
                        ),
                      ),
                      const SizedBox(height: AppDimens.p24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ảnh minh họa phóng to dần với hiệu ứng "nảy"
class _AnimatedIllustration extends StatelessWidget {
  const _AnimatedIllustration();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
      child: Container(
        width: 260,
        height: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.6),
              AppColors.secondary.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            AppAssets.orderSuccess,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.check_circle_rounded,
              size: 140,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  final OrderResult result;

  const _OrderInfoCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final time = result.createdAt;
    final timeLabel =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder, width: 0.8),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.receipt_long_rounded,
            label: 'Mã đơn hàng',
            value: '#${result.orderCode}',
          ),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Đặt lúc',
            value: timeLabel,
          ),
          _InfoRow(
            icon: Icons.delivery_dining_rounded,
            label: 'Dự kiến giao',
            value: '~${result.estimatedTime.inMinutes} phút',
          ),
          _InfoRow(
            icon: Icons.local_cafe_rounded,
            label: 'Số phần',
            value: '${result.totalQuantity}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.lightBorder),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng thanh toán', style: AppTextStyles.subtitle.copyWith(fontSize: 15)),
              Text(
                CurrencyFormatter.vnd(result.totalAmount),
                style: AppTextStyles.price.copyWith(fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.bodyMediumSecondary),
          const Spacer(),
          Text(value, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

/// Hiệu ứng mờ dần + trượt lên, có độ trễ để tạo nhịp xuất hiện tuần tự
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeSlideIn({required this.child, this.delay = Duration.zero});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
