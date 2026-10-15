import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_snackbar.dart';

/// BottomSheet Trung tâm Hỗ trợ & Liên hệ
class SupportCenterSheet extends StatelessWidget {
  const SupportCenterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SupportCenterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thanh kéo
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
                const SizedBox(height: 14),

                // Tiêu đề
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 26),
                        const SizedBox(width: 8),
                        Text('Trung Tâm Hỗ Trợ', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 1. Hotline & Kênh liên hệ nhanh
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimens.r16),
                    border: Border.all(color: AppColors.lightBorder),
                    boxShadow: [AppColors.cardShadow],
                  ),
                  child: Column(
                    children: [
                      // Hotline
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A651).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF00A651), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hotline Chăm Sóc Khách Hàng', style: AppTextStyles.caption),
                                Text(
                                  '1900 6868',
                                  style: AppTextStyles.subtitle.copyWith(
                                    fontSize: 16,
                                    color: const Color(0xFF00A651),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showCallDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A651),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r10)),
                            ),
                            child: const Text('Gọi Ngay', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: AppColors.lightBorder),
                      // Email & Giờ làm việc
                      Row(
                        children: [
                          const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Email: hotro@aromapremium.vn', style: AppTextStyles.bodyMediumSecondary.copyWith(fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Thời gian phục vụ: 07:00 - 22:30 mỗi ngày', style: AppTextStyles.bodyMediumSecondary.copyWith(fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Câu hỏi thường gặp (FAQ)
                Text(
                  'Câu Hỏi Thường Gặp (FAQ)',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 10),

                _buildFaqItem(
                  question: 'Thời gian giao hàng trung bình là bao lâu?',
                  answer:
                      'Đơn hàng thường được chuẩn bị và giao đến bạn trong vòng 15 đến 25 phút đối với các chi nhánh trong bán kính 5km. Bạn có thể theo dõi vị trí tài xế theo thời gian thực tại màn hình Theo dõi đơn hàng.',
                ),
                _buildFaqItem(
                  question: 'Chính sách hoàn tiền / đổi trả khi đồ uống có vấn đề?',
                  answer:
                      'Aroma Coffee cam kết bảo vệ quyền lợi khách hàng 100%. Nếu thức uống bị đổ vỡ, sai topping hoặc không đúng hương vị yêu cầu, quán sẽ lập tức giao lại món mới miễn phí hoặc hoàn tiền qua tài khoản trong vòng 15 phút.',
                ),
                _buildFaqItem(
                  question: 'Hạng thành viên & cách thức tích lũy điểm thưởng?',
                  answer:
                      'Với mỗi 10.000 VNĐ chi tiêu, bạn tích lũy được 1 điểm AromaPoint. Thành viên Hạng Vàng được tặng voucher sinh nhật 50.000đ và ưu tiên giao hàng giờ cao điểm. Tích lũy đủ 2.000 điểm sẽ tự động nâng lên Hạng Kim Cương với ưu đãi giảm 15% trọn đời.',
                ),
                _buildFaqItem(
                  question: 'Làm thế nào để áp dụng mã giảm giá / Voucher?',
                  answer:
                      'Tại màn hình Xác nhận đơn hàng (Checkout), bạn nhấn vào mục "Ưu đãi / Chọn mã khuyến mãi". Bạn có thể chọn voucher có sẵn trong kho hoặc gõ các mã như FREESHIP, COFFEE10, VIP20 để nhận ưu đãi ngay.',
                ),

                const SizedBox(height: 14),

                // Nút Gửi phản hồi
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showFeedbackDialog(context),
                    icon: const Icon(Icons.rate_review_outlined, size: 18, color: AppColors.primary),
                    label: Text(
                      'Gửi ý kiến đóng góp cho Aroma Coffee',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          title: Text(
            question,
            style: AppTextStyles.subtitle.copyWith(fontSize: 13.5),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: [
            Text(
              answer,
              style: AppTextStyles.bodyMediumSecondary.copyWith(fontSize: 13, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r20)),
        title: const Text('Gọi Tổng Đài 1900 6868', textAlign: TextAlign.center),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_in_talk_rounded, color: Color(0xFF00A651), size: 48),
            SizedBox(height: 12),
            Text(
              'Đang kết nối tới tổng đài viên CSKH Aroma Coffee...\n(Cước phí 1.000đ/phút)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Kết Thúc Cuộc Gọi', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r20)),
        title: const Text('Đóng Góp Ý Kiến'),
        content: TextField(
          controller: feedbackCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Nhập cảm nhận hoặc góp ý của bạn về dịch vụ quán...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppSnackBar.success(context, '🙏 Cảm ơn bạn đã gửi ý kiến đóng góp quý báu!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Gửi Ý Kiến', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
