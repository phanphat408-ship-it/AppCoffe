import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../cart/data/models/checkout_models.dart';
import '../../data/models/order_tracking_model.dart';

/// Card hiển thị chi tiết đơn hàng kết hợp Timeline UI 4 bước
/// và Card Thông tin Tài xế mô phỏng chuẩn siêu ứng dụng Grab / Be / Xanh SM.
class OrderTimelineCard extends StatelessWidget {
  final TrackedOrder order;
  final bool isLiveOrder;
  final bool isSimulating;
  final int countdownSeconds;
  final VoidCallback? onNextStepTap;
  final VoidCallback? onToggleSimulation;

  const OrderTimelineCard({
    super.key,
    required this.order,
    this.isLiveOrder = false,
    this.isSimulating = true,
    this.countdownSeconds = 6,
    this.onNextStepTap,
    this.onToggleSimulation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r20),
        border: Border.all(
          color: isLiveOrder ? AppColors.primary.withValues(alpha: 0.5) : AppColors.lightBorder,
          width: isLiveOrder ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLiveOrder ? 0.08 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Mã đơn + Thời gian + Badge trạng thái
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppDimens.r12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn hàng #${order.orderCode}',
                        style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.orderTime.hour.toString().padLeft(2, '0')}:${order.orderTime.minute.toString().padLeft(2, '0')} • ${order.paymentMethodTitle}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order.currentStep),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // 2. Timeline UI 4 bước trực quan
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: _buildTimeline(order.currentStep),
          ),

          // 4. Lời chú thích bước hiện tại
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimens.r12),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Icon(
                  _getStepIcon(order.currentStep),
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.currentStep.title,
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.currentStep.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. Card Thông tin Tài xế mô phỏng chuẩn Grab / Be / Xanh SM
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _buildDriverCard(context, order.driver),
          ),

          const SizedBox(height: 12),

          // 6. Danh sách món & Chi nhánh & Tổng tiền
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.branchName,
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
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
                const SizedBox(height: 10),
                Text(
                  'Chi tiết đơn (${order.items.length} món)',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.name}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.vnd(item.price),
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tổng thanh toán:', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                    Text(
                      CurrencyFormatter.vnd(order.totalAmount),
                      style: AppTextStyles.price.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Card thông tin Tài xế mô phỏng (Grab / Be / Xanh SM)
  Widget _buildDriverCard(BuildContext context, DriverInfo driver) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r14),
        border: Border.all(color: driver.brandColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: driver.brandColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar Tài xế
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.rFull),
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: AppNetworkImage(
                    imageUrl: driver.avatarUrl,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.person_rounded,
                    cacheWidth: 100,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: driver.brandColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.two_wheeler_rounded, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Thông tin tài xế
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        driver.name,
                        style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: driver.brandColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimens.r4),
                      ),
                      child: Text(
                        driver.serviceBrand,
                        style: TextStyle(
                          color: driver.brandColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${driver.vehicleModel} • ${driver.licensePlate}',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.rating, size: 14),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${driver.rating} (${driver.totalTrips}+ chuyến)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Nút Gọi điện & Nhắn tin
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconButton(
                icon: Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                tooltip: 'Nhắn tin cho tài xế',
                onTap: () => _showChatSimulationModal(context, driver),
              ),
              const SizedBox(width: 6),
              _buildIconButton(
                icon: Icons.phone_in_talk_rounded,
                color: const Color(0xFF2E7D32),
                tooltip: 'Gọi điện cho tài xế',
                onTap: () => _showCallSimulationDialog(context, driver),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  /// Dialog giả lập cuộc gọi với tài xế
  void _showCallSimulationDialog(BuildContext context, DriverInfo driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: driver.brandColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.phone_in_talk_rounded, size: 40, color: driver.brandColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Đang kết nối cuộc gọi...',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              driver.name,
              style: AppTextStyles.subtitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              '${driver.phone} (${driver.serviceBrand})',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimens.r12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text('00:03 - Đang đàm thoại', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r12)),
              ),
              icon: const Icon(Icons.call_end_rounded, size: 18),
              label: const Text('Kết thúc cuộc gọi'),
            ),
          ],
        ),
      ),
    );
  }

  /// Khung Chat mô phỏng tương tác với tài xế
  void _showChatSimulationModal(BuildContext context, DriverInfo driver) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DriverChatModal(driver: driver),
    );
  }

  /// Timeline UI kết hợp Row 4 bước và Line kết nối
  Widget _buildTimeline(OrderStep current) {
    const steps = OrderStep.values;

    return Column(
      children: [
        // Hàng icon và đường nối
        Row(
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              // Node bước
              _buildStepNode(steps[i], current),
              // Line nối giữa các node (trừ node cuối)
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 3,
                    color: i < current.index
                        ? AppColors.primary
                        : AppColors.lightBorder,
                  ),
                ),
            ],
          ],
        ),

        const SizedBox(height: 8),

        // Hàng nhãn tên bước
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final step in steps)
              SizedBox(
                width: 72,
                child: Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    fontWeight: step == current ? FontWeight.w700 : FontWeight.w500,
                    color: step.index <= current.index
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepNode(OrderStep step, OrderStep current) {
    final isDone = step.index < current.index;
    final isActive = step == current;

    Color bgColor = AppColors.lightBorder;
    Color iconColor = AppColors.textSecondary;

    if (isDone || isActive) {
      bgColor = AppColors.primary;
      iconColor = Colors.white;
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          isDone ? Icons.check_rounded : _getStepIcon(step),
          size: 16,
          color: iconColor,
        ),
      ),
    );
  }

  IconData _getStepIcon(OrderStep step) {
    switch (step) {
      case OrderStep.received:
        return Icons.receipt_long_rounded;
      case OrderStep.preparing:
        return Icons.coffee_rounded;
      case OrderStep.delivering:
        return Icons.two_wheeler_rounded;
      case OrderStep.completed:
        return Icons.check_circle_rounded;
    }
  }

  Widget _buildStatusBadge(OrderStep step) {
    Color bg = AppColors.secondary.withValues(alpha: 0.5);
    Color fg = AppColors.primary;

    if (step == OrderStep.completed) {
      bg = AppColors.success.withValues(alpha: 0.15);
      fg = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.rFull),
      ),
      child: Text(
        step.title,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Modal Chat tương tác mô phỏng với tài xế
class _DriverChatModal extends StatefulWidget {
  final DriverInfo driver;

  const _DriverChatModal({required this.driver});

  @override
  State<_DriverChatModal> createState() => _DriverChatModalState();
}

class _DriverChatModalState extends State<_DriverChatModal> {
  final List<({String text, bool isMe, String time})> _messages = [
    (
      text: 'Chào bạn! Em là Sinh tài xế Xanh SM. Em vừa nhận đơn của quán và đang đi giao tới bạn nhé!',
      isMe: false,
      time: '12:02'
    ),
  ];

  final TextEditingController _controller = TextEditingController();

  final List<String> _quickReplies = [
    'Tôi đang đợi ở sảnh nhé!',
    'Đến nơi hãy gọi điện cho tôi',
    'Gửi đồ uống ở bàn lễ tân giúp tôi',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add((text: text.trim(), isMe: true, time: timeStr));
    });
    _controller.clear();

    // Giả lập tài xế phản hồi sau 1.5 giây
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _messages.add((
            text: 'Dạ em ghi nhận rồi ạ, em đang chạy xe tới ngay nhé!',
            isMe: false,
            time: '${now.hour.toString().padLeft(2, '0')}:${(now.minute + 1).toString().padLeft(2, '0')}'
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
      ),
      child: Column(
        children: [
          // Header Chat
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: widget.driver.brandColor.withValues(alpha: 0.15),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.driver.name, style: AppTextStyles.subtitle.copyWith(fontSize: 15)),
                      Text('${widget.driver.serviceBrand} • Đang online', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Danh sách tin nhắn
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isMe ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimens.r14).copyWith(
                        bottomRight: msg.isMe ? Radius.zero : const Radius.circular(AppDimens.r14),
                        bottomLeft: !msg.isMe ? Radius.zero : const Radius.circular(AppDimens.r14),
                      ),
                      border: msg.isMe ? null : Border.all(color: AppColors.lightBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isMe ? Colors.white : AppColors.textPrimary,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          msg.time,
                          style: TextStyle(
                            color: msg.isMe ? Colors.white70 : AppColors.textLight,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Gợi ý tin nhắn nhanh
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickReplies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final reply = _quickReplies[index];
                return ActionChip(
                  label: Text(reply, style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.background,
                  side: const BorderSide(color: AppColors.lightBorder),
                  onPressed: () => _sendMessage(reply),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Ô nhập tin nhắn
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Nhắn cho tài xế...',
                      hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.rFull),
                        borderSide: const BorderSide(color: AppColors.lightBorder),
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded, size: 20),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
