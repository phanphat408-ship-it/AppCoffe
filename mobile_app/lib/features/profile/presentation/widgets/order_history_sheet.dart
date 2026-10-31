import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/presentation/controllers/cart_notifier.dart';
import '../../../home/data/models/product_model.dart';
import '../../../orders/data/models/order_tracking_model.dart';
import '../../../orders/presentation/controllers/order_tracking_notifier.dart';

/// BottomSheet Lịch sử đơn hàng (3 Tab: Đang xử lý, Đã hoàn thành, Đã hủy)
class OrderHistorySheet extends ConsumerStatefulWidget {
  const OrderHistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OrderHistorySheet(),
    );
  }

  @override
  ConsumerState<OrderHistorySheet> createState() => _OrderHistorySheetState();
}

class _OrderHistorySheetState extends ConsumerState<OrderHistorySheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = ref.watch(orderTrackingNotifierProvider.select((s) => s.orders));

    // Phân loại đơn: Đang xử lý (bước != completed), Đã hoàn thành (bước == completed)
    final processingOrders =
        activeOrders.where((o) => o.currentStep != OrderStep.completed).toList();
    final completedOrders =
        activeOrders.where((o) => o.currentStep == OrderStep.completed).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(AppDimens.rFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 24),
                          const SizedBox(width: 8),
                          Text('Lịch Sử Đơn Hàng', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.subtitle.copyWith(fontSize: 13.5),
                    unselectedLabelStyle: AppTextStyles.bodyMediumSecondary.copyWith(fontSize: 13.5),
                    tabs: [
                      Tab(text: 'Đang xử lý (${processingOrders.length})'),
                      Tab(text: 'Đã hoàn tất (${completedOrders.length})'),
                      const Tab(text: 'Đã hủy (0)'),
                    ],
                  ),
                ],
              ),
            ),

            // Nội dung các Tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Đang xử lý
                  _buildOrderList(processingOrders, isProcessing: true),

                  // Tab 2: Đã hoàn thành
                  _buildOrderList(completedOrders, isProcessing: false),

                  // Tab 3: Đã hủy (trống)
                  _buildEmptyCancelled(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<TrackedOrder> orders, {required bool isProcessing}) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isProcessing ? Icons.hourglass_empty_rounded : Icons.task_alt_rounded,
                size: 56,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 12),
              Text(
                isProcessing ? 'Không có đơn nào đang xử lý' : 'Chưa có đơn hàng hoàn thành nào',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      cacheExtent: 300,
      addRepaintBoundaries: true,
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (ctx, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildEmptyCancelled() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 56, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text(
            'Bạn không có đơn hàng nào bị hủy',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Cảm ơn bạn đã luôn tin tưởng dịch vụ của chúng tôi!',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(TrackedOrder order) {
    final statusColor = order.currentStep == OrderStep.completed
        ? const Color(0xFF00A651)
        : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header đơn: Mã đơn + Trạng thái
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimens.r8),
                    ),
                    child: const Icon(Icons.local_cafe_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#${order.orderCode}',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 14.5),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.rFull),
                ),
                child: Text(
                  order.currentStep.title,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: AppColors.lightBorder),

          // Chi nhánh & thời gian
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.branchName,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.payment_rounded, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Thanh toán: ${order.paymentMethodTitle}',
                style: AppTextStyles.caption,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tóm tắt món
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimens.r10),
            ),
            child: Column(
              children: [
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.name}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.vnd(item.price),
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tổng tiền + Nút Đặt lại
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng thanh toán', style: AppTextStyles.caption),
                  Text(
                    CurrencyFormatter.vnd(order.totalAmount),
                    style: AppTextStyles.price.copyWith(fontSize: 16, color: AppColors.primary),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _handleReorder(order.items),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.r10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.replay_rounded, size: 16, color: AppColors.primary),
                label: Text(
                  'Đặt lại',
                  style: AppTextStyles.button.copyWith(color: AppColors.primary, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Xử lý Đặt lại (Re-order): Đẩy món cũ vào giỏ và mở giỏ hàng
  void _handleReorder(List<OrderItemSummary> items) {
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final unitPrice = item.quantity > 0 ? (item.price / item.quantity).round() : item.price;
      final product = ProductModel(
        id: 100 + i,
        name: item.name,
        price: unitPrice.toDouble(),
        imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=600',
        categoryId: 1,
      );
      cartNotifier.addToCart(product, item.quantity);
    }

    Navigator.pop(context);
    AppSnackBar.success(context, '🛒 Đã thêm các món từ đơn hàng vào giỏ hàng!');
    context.push(AppRoutes.cart);
  }
}
