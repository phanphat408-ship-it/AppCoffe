import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/app_snackbar.dart';
import '../data/models/cart_item.dart';
import 'controllers/cart_notifier.dart';
import 'controllers/checkout_notifier.dart';
import 'widgets/cart_confirm_dialog.dart';
import 'widgets/cart_empty_view.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/cart_note_field.dart';
import 'widgets/cart_order_summary.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartNotifierProvider);
    final isSubmitting = ref.watch(
      checkoutNotifierProvider.select((s) => s.isSubmitting),
    );

    return PopScope(
      // Không cho rời màn hình khi đơn hàng đang được gửi
      canPop: !isSubmitting,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: Text('Giỏ Hàng', style: AppTextStyles.h3),
          leading: IconButton(
            tooltip: 'Quay lại',
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: isSubmitting ? null : () => _goBack(context),
          ),
          actions: [
            if (items.isNotEmpty)
              TextButton.icon(
                onPressed: isSubmitting ? null : () => _confirmClearCart(context, ref),
                icon: const Icon(Icons.delete_sweep_outlined, size: 20, color: AppColors.error),
                label: Text(
                  'Xóa hết',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: items.isEmpty
              ? CartEmptyView(
                  key: const ValueKey('cart-empty'),
                  onBrowseMenu: () => context.go(AppRoutes.home),
                )
              : _CartContent(
                  key: const ValueKey('cart-content'),
                  items: items,
                  enabled: !isSubmitting,
                ),
        ),
        bottomNavigationBar: items.isEmpty
            ? null
            : Consumer(
                builder: (context, sumRef, child) => CartOrderSummary(
                  subtotal: sumRef.watch(cartTotalProvider),
                  deliveryFee: sumRef.watch(deliveryFeeProvider),
                  total: sumRef.watch(cartGrandTotalProvider),
                  itemCount: sumRef.watch(cartItemCountProvider),
                  isSubmitting: isSubmitting,
                  onPlaceOrder: () => _placeOrder(context, ref),
                ),
              ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _confirmClearCart(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCartConfirmDialog(
      context,
      title: 'Xóa toàn bộ giỏ hàng?',
      message: 'Tất cả món bạn đã chọn sẽ bị xóa khỏi giỏ hàng.',
      confirmLabel: 'Xóa hết',
    );
    if (confirmed) {
      ref.read(cartNotifierProvider.notifier).clearCart();
    }
  }

  /// Luồng chuyển sang màn hình Xác nhận đơn hàng & Thanh toán (Checkout)
  void _placeOrder(BuildContext context, WidgetRef ref) {
    FocusScope.of(context).unfocus();
    context.push(AppRoutes.checkout);
  }
}

/// Danh sách món + ô ghi chú
class _CartContent extends ConsumerWidget {
  final List<CartItem> items;
  final bool enabled;

  const _CartContent({super.key, required this.items, required this.enabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartNotifierProvider.notifier);

    return AbsorbPointer(
      absorbing: !enabled,
      child: ListView(
        cacheExtent: 300,
        addRepaintBoundaries: true,
        padding: const EdgeInsets.fromLTRB(
          AppDimens.p24,
          AppDimens.p8,
          AppDimens.p24,
          AppDimens.p24,
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Row(
            children: [
              Text('Món đã chọn', style: AppTextStyles.subtitle),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppDimens.rFull),
                ),
                child: Text(
                  '${items.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text('Vuốt trái để xóa', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: AppDimens.p12),

          for (final item in items) ...[
            CartItemTile(
              key: ValueKey(item.id),
              item: item,
              canIncrement: item.quantity < CartConfig.maxQuantityPerItem,
              onIncrement: () => _safeUpdate(
                context,
                () => notifier.updateQuantity(item.id, item.quantity + 1),
              ),
              onDecrement: () => _decrement(context, ref, item),
              confirmDismiss: () => _confirmRemove(context, item),
              onDismissed: () => _removeWithUndo(context, ref, item),
            ),
            const SizedBox(height: AppDimens.p12),
          ],

          const SizedBox(height: AppDimens.p8),
          CartNoteField(
            initialValue: ref.read(cartNoteProvider),
            maxLength: CartConfig.maxNoteLength,
            enabled: enabled,
            onChanged: (value) => ref.read(cartNoteProvider.notifier).setNote(value),
          ),
        ],
      ),
    );
  }

  /// Giảm số lượng. Nếu đang là 1 -> giảm về 0 phải hỏi xác nhận xóa.
  Future<void> _decrement(BuildContext context, WidgetRef ref, CartItem item) async {
    final notifier = ref.read(cartNotifierProvider.notifier);

    if (item.quantity > 1) {
      _safeUpdate(context, () => notifier.updateQuantity(item.id, item.quantity - 1));
      return;
    }

    final confirmed = await _confirmRemove(context, item);
    if (!confirmed || !context.mounted) return;
    _removeWithUndo(context, ref, item);
  }

  Future<bool> _confirmRemove(BuildContext context, CartItem item) {
    return showCartConfirmDialog(
      context,
      title: 'Xóa món khỏi giỏ?',
      message: 'Bạn có chắc muốn xóa "${item.product.name}" khỏi giỏ hàng không?',
    );
  }

  void _removeWithUndo(BuildContext context, WidgetRef ref, CartItem item) {
    final notifier = ref.read(cartNotifierProvider.notifier);
    notifier.removeFromCart(item.id);

    AppSnackBar.success(
      context,
      'Đã xóa "${item.product.name}"',
      actionLabel: 'HOÀN TÁC',
      onAction: () {
        notifier.addCustomizedItem(
          product: item.product,
          quantity: item.quantity,
          selectedSize: item.selectedSize,
          sizeExtraPrice: item.sizeExtraPrice,
          selectedSugar: item.selectedSugar,
          selectedIce: item.selectedIce,
          selectedToppings: item.selectedToppings,
          toppingExtraPrice: item.toppingExtraPrice,
          note: item.note,
        );
      },
    );
  }

  void _safeUpdate(BuildContext context, VoidCallback action) {
    try {
      action();
    } on CartException catch (e) {
      AppSnackBar.error(context, e.message);
    }
  }
}
