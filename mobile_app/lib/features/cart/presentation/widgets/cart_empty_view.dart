import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// Empty State thân thiện khi giỏ hàng không có món nào.
class CartEmptyView extends StatelessWidget {
  final VoidCallback onBrowseMenu;

  const CartEmptyView({super.key, required this.onBrowseMenu});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutBack,
          builder: (context, value, child) => Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.scale(scale: 0.85 + 0.15 * value, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.25),
                ),
                padding: const EdgeInsets.all(18),
                child: ClipOval(
                  child: Image.asset(
                    AppAssets.emptyCart,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.shopping_bag_outlined,
                      size: 96,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Giỏ hàng của bạn đang rỗng.\nHãy chọn món nhé!',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 10),
              Text(
                'Hàng chục món cà phê, trà và bánh ngọt thơm ngon đang chờ bạn khám phá.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMediumSecondary,
              ),
              const SizedBox(height: 28),
              AppButton(
                title: 'Khám phá thực đơn',
                width: 240,
                height: AppDimens.buttonHeightSmall + 6,
                onPressed: onBrowseMenu,
                icon: const Icon(Icons.local_cafe_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
