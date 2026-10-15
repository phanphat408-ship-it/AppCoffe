import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/cart_item.dart';
import 'quantity_stepper.dart';

/// Một dòng món trong giỏ: ảnh, tên, tùy chọn size/đường/đá/topping, đơn giá, thành tiền và bộ [-] n [+].
/// Hỗ trợ vuốt sang trái để xóa (có xác nhận).
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final bool canIncrement;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  /// Gọi khi người dùng vuốt xóa – trả về `true` để xác nhận xóa
  final Future<bool> Function()? confirmDismiss;
  final VoidCallback? onDismissed;

  const CartItemTile({
    super.key,
    required this.item,
    this.canIncrement = true,
    this.onIncrement,
    this.onDecrement,
    this.confirmDismiss,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder, width: 0.8),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh thumbnail món ăn sử dụng AppNetworkImage an toàn
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.r12),
            child: SizedBox(
              width: 76,
              height: 76,
              child: AppNetworkImage(
                imageUrl: item.product.imageUrl,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                fallbackIcon: Icons.local_cafe_rounded,
                cacheWidth: 400,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Hiển thị các tùy chọn (Size, Đường, Đá, Topping, Ghi chú)
                if (item.optionsSummary.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppDimens.r6),
                    ),
                    child: Text(
                      item.optionsSummary,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${item.formattedUnitPrice} / phần',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          item.formattedLineTotal,
                          key: ValueKey(item.lineTotal),
                          style: AppTextStyles.price.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    QuantityStepper(
                      quantity: item.quantity,
                      onDecrement: onDecrement,
                      onIncrement: canIncrement ? onIncrement : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirmDismiss == null) return card;

    return Dismissible(
      key: ValueKey('cart-item-${item.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDismiss!(),
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimens.r16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Xóa',
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 14,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.delete_outline_rounded, color: AppColors.error),
          ],
        ),
      ),
      child: card,
    );
  }
}
