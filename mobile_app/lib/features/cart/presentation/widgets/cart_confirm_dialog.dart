import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Dialog xác nhận chung cho giỏ hàng. Trả về `true` khi người dùng đồng ý.
Future<bool> showCartConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Xóa',
  String cancelLabel = 'Giữ lại',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.r20),
      ),
      icon: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 28),
      ),
      title: Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
      content: Text(
        message,
        style: AppTextStyles.bodyMediumSecondary,
        textAlign: TextAlign.center,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.lightBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.r16),
                  ),
                ),
                child: Text(
                  cancelLabel,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.r16),
                  ),
                ),
                child: Text(
                  confirmLabel,
                  style: AppTextStyles.button.copyWith(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // Đóng dialog bằng cách chạm ra ngoài / nút back -> coi như "Giữ lại"
  return result ?? false;
}
