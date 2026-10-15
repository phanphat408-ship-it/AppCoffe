import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../orders/data/models/order_tracking_model.dart';
import '../../../orders/presentation/controllers/order_tracking_notifier.dart';

/// BottomSheet Quản Lý & Duyệt Đơn Hàng dành cho Admin / Quản lý cửa hàng
class AdminOrderManagementSheet extends ConsumerStatefulWidget {
  const AdminOrderManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdminOrderManagementSheet(),
    );
  }

  @override
  ConsumerState<AdminOrderManagementSheet> createState() =>
      _AdminOrderManagementSheetState();
}

class _AdminOrderManagementSheetState
    extends ConsumerState<AdminOrderManagementSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(orderTrackingNotifierProvider);
    final allOrders = trackingState.orders;

    final pendingOrders =
        allOrders.where((o) => o.currentStep == OrderStep.received).toList();
    final preparingOrders =
        allOrders.where((o) => o.currentStep == OrderStep.preparing).toList();
    final deliveringOrders =
        allOrders.where((o) => o.currentStep == OrderStep.delivering).toList();
    final completedOrders =
        allOrders.where((o) => o.currentStep == OrderStep.completed).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header Top
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(AppDimens.rFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimens.r12),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: Color(0xFF2E7D32),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quản Lý Đơn Hàng',
                              style: AppTextStyles.h3.copyWith(fontSize: 18),
                            ),
                            Text(
                              'Duyệt đơn, bắt đầu pha chế & giao tài xế',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Nút tạo đơn giả lập nhanh cho demo
                      IconButton(
                        tooltip: 'Thêm đơn mới giả lập để demo',
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppDimens.r8),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(orderTrackingNotifierProvider.notifier)
                              .addMockPendingOrder();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✨ Đã tạo thêm 1 đơn hàng mới đang chờ duyệt!'),
                              backgroundColor: AppColors.primary,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF2E7D32),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF2E7D32),
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle:
                        AppTextStyles.subtitle.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                    unselectedLabelStyle:
                        AppTextStyles.bodyMediumSecondary.copyWith(fontSize: 13),
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: 'Tất cả (${allOrders.length})'),
                      Tab(text: 'Chờ duyệt (${pendingOrders.length})'),
                      Tab(text: 'Đang pha chế (${preparingOrders.length})'),
                      Tab(text: 'Đang giao & Xong (${deliveringOrders.length + completedOrders.length})'),
                    ],
                  ),
                ],
              ),
            ),

            // Tab View Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(allOrders),
                  _buildOrderList(pendingOrders),
                  _buildOrderList(preparingOrders),
                  _buildOrderList([...deliveringOrders, ...completedOrders]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<TrackedOrder> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [AppColors.cardShadow],
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Không có đơn hàng nào ở mục này',
              style: AppTextStyles.subtitle.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Các đơn hàng mới sẽ tự động hiển thị tại đây',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildAdminOrderCard(order);
      },
    );
  }

  Widget _buildAdminOrderCard(TrackedOrder order) {
    final statusColor = _getStatusColor(order.currentStep);
    final statusBadge = _getStatusBadge(order.currentStep);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r18),
        border: Border.all(
          color: order.currentStep == OrderStep.received
              ? const Color(0xFFE65100).withValues(alpha: 0.4)
              : AppColors.lightBorder,
          width: order.currentStep == OrderStep.received ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card: Mã đơn + Badge trạng thái
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.r18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_rounded, size: 17, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '#${order.orderCode}',
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(AppDimens.rFull),
                  ),
                  child: Text(
                    statusBadge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Khách hàng & SĐT
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      order.customerName,
                      style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimens.r6),
                      ),
                      child: Text(
                        order.customerPhone,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Địa chỉ giao
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: AppColors.divider),
                ),

                // Danh sách món ăn
                Text(
                  'Chi tiết món (${order.items.length} món):',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '• ${item.name} x${item.quantity}',
                            style: AppTextStyles.bodyMediumSecondary.copyWith(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.vnd(item.price.toDouble()),
                          style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Tổng tiền & Thanh toán
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDimens.r12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.payments_outlined,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            order.paymentMethodTitle,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.vnd(order.totalAmount.toDouble()),
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Cụm Nút Hành Động Phân Quyền Admin (Xác nhận & Pha chế / Giao cho tài xế)
                _buildOrderActionButtons(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActionButtons(TrackedOrder order) {
    final notifier = ref.read(orderTrackingNotifierProvider.notifier);

    switch (order.currentStep) {
      case OrderStep.received:
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: () {
                  notifier.updateOrderStep(order.orderCode, OrderStep.preparing);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Đã duyệt đơn #${order.orderCode}! Barista đang pha chế món.',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF1976D2),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.r12),
                  ),
                ),
                icon: const Icon(Icons.coffee_rounded, size: 18),
                label: const Text(
                  'Xác nhận & Pha chế',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Từ chối đơn',
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
              onPressed: () {
                _showRejectDialog(order.orderCode);
              },
            ),
          ],
        );

      case OrderStep.preparing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              notifier.updateOrderStep(order.orderCode, OrderStep.delivering);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.delivery_dining_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đơn #${order.orderCode} đã pha chế xong, bàn giao cho tài xế!',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF6A1B9A),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.r12),
              ),
            ),
            icon: const Icon(Icons.moped_rounded, size: 18),
            label: const Text(
              'Giao cho tài xế',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
        );

      case OrderStep.delivering:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              notifier.updateOrderStep(order.orderCode, OrderStep.completed);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.task_alt_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đơn #${order.orderCode} đã giao thành công và hoàn tất!',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF2E7D32),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.r12),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text(
              'Xác nhận Hoàn tất Đơn',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
        );

      case OrderStep.completed:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimens.r10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_rounded, size: 16, color: Color(0xFF2E7D32)),
              SizedBox(width: 6),
              Text(
                'Đơn hàng đã hoàn thành trọn vẹn',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
    }
  }

  void _showRejectDialog(String orderCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.r18),
        ),
        title: const Text('Từ chối đơn hàng?'),
        content: Text('Bạn có chắc chắn muốn hủy đơn #$orderCode do hết nguyên liệu hoặc quán quá tải?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã từ chối đơn #$orderCode'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận Hủy'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStep step) {
    switch (step) {
      case OrderStep.received:
        return const Color(0xFFE65100);
      case OrderStep.preparing:
        return const Color(0xFF1976D2);
      case OrderStep.delivering:
        return const Color(0xFF6A1B9A);
      case OrderStep.completed:
        return const Color(0xFF2E7D32);
    }
  }

  String _getStatusBadge(OrderStep step) {
    switch (step) {
      case OrderStep.received:
        return '⏳ Chờ Quán Duyệt';
      case OrderStep.preparing:
        return '☕ Đang Pha Chế';
      case OrderStep.delivering:
        return '🛵 Đang Giao Hàng';
      case OrderStep.completed:
        return '✅ Đã Hoàn Tất';
    }
  }
}
