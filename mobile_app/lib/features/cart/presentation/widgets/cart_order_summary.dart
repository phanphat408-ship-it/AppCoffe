import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';

/// Tóm tắt đơn hàng cố định ở đáy màn hình + nút "Đặt Hàng".
class CartOrderSummary extends StatelessWidget {
  final int subtotal;
  final int deliveryFee;
  final int total;
  final int itemCount;
  final bool isSubmitting;
  final VoidCallback? onPlaceOrder;

  const CartOrderSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.itemCount,
    this.isSubmitting = false,
    this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(
              label: 'Tổng tiền món ($itemCount phần)',
              value: CurrencyFormatter.vnd(subtotal),
            ),
            const SizedBox(height: 10),
            _SummaryRow(
              label: 'Phí giao hàng',
              value: CurrencyFormatter.vnd(deliveryFee),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: AppColors.lightBorder),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng thanh toán', style: AppTextStyles.subtitle),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, 0.3), end: Offset.zero)
                          .animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    CurrencyFormatter.vnd(total),
                    key: ValueKey(total),
                    style: AppTextStyles.price.copyWith(fontSize: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppButton(
              title: 'Tiến hành thanh toán',
              isLoading: isSubmitting,
              onPressed: onPlaceOrder,
              icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMediumSecondary),
        Text(value, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
      ],
    );
  }
}
