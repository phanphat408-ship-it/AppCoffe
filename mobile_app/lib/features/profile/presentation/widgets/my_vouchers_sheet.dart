import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../cart/data/models/checkout_models.dart';
import '../../../main/presentation/screens/main_screen.dart';

/// BottomSheet Kho Voucher & Ưu đãi của tôi
class MyVouchersSheet extends ConsumerWidget {
  const MyVouchersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MyVouchersSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const vouchers = VoucherModel.availableVouchers;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      const Icon(Icons.confirmation_num_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text('Kho Voucher Của Tôi', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Danh sách Voucher
              Expanded(
                child: ListView.separated(
                  cacheExtent: 300,
                  addRepaintBoundaries: true,
                  itemCount: vouchers.length,
                  separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final voucher = vouchers[index];
                    return _buildVoucherTicket(context, ref, voucher);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherTicket(BuildContext context, WidgetRef ref, VoucherModel voucher) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          // Cột bên trái: Icon + nhãn coupon
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppDimens.r16)),
              border: const Border(right: BorderSide(color: AppColors.lightBorder, style: BorderStyle.solid)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.discount_rounded, color: AppColors.primary, size: 28),
                const SizedBox(height: 6),
                Text(
                  voucher.code,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Cột bên phải: Chi tiết + Nút Sao chép & Dùng ngay
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.title,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voucher.description,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HSD: ${voucher.expiryDate}',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                      Row(
                        children: [
                          // Nút copy
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: voucher.code));
                              AppSnackBar.success(context, 'Đã sao chép mã "${voucher.code}"');
                            },
                            borderRadius: BorderRadius.circular(AppDimens.r8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(AppDimens.r8),
                              ),
                              child: Text(
                                'Sao chép',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Nút dùng ngay
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              ref.read(mainTabIndexProvider.notifier).setTab(0);
                              context.go(AppRoutes.home);
                            },
                            borderRadius: BorderRadius.circular(AppDimens.r8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(AppDimens.r8),
                              ),
                              child: Text(
                                'Dùng ngay',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
