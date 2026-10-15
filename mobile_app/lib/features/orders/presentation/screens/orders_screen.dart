import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../controllers/order_tracking_notifier.dart';
import '../widgets/order_timeline_card.dart';

/// Màn hình Theo dõi đơn hàng (Order Tracking Screen)
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(orderTrackingNotifierProvider);
    final notifier = ref.read(orderTrackingNotifierProvider.notifier);
    final orders = trackingState.orders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('Theo Dõi Đơn Hàng', style: AppTextStyles.h3),
        actions: [
          IconButton(
            tooltip: trackingState.isSimulating ? 'Tạm dừng mô phỏng' : 'Bật mô phỏng',
            icon: Icon(
              trackingState.isSimulating ? Icons.timer_rounded : Icons.timer_off_outlined,
              color: trackingState.isSimulating ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: () => notifier.toggleSimulation(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text('Bạn chưa có đơn hàng nào', style: AppTextStyles.subtitle),
                ],
              ),
            )
          : ListView.separated(
              cacheExtent: 300,
              addRepaintBoundaries: true,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = orders[index];
                final isLive = index == 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index == 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ĐƠN HÀNG ĐANG XỬ LÝ',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (index == 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
                        child: Text(
                          'LỊCH SỬ ĐƠN HÀNG',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    OrderTimelineCard(
                      order: order,
                      isLiveOrder: isLive,
                      isSimulating: trackingState.isSimulating,
                      countdownSeconds: trackingState.countdownSeconds,
                      onNextStepTap: () => notifier.advanceStep(),
                      onToggleSimulation: () => notifier.toggleSimulation(),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
