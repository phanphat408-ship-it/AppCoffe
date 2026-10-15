import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../controllers/app_settings_notifier.dart';

/// BottomSheet Cài đặt ứng dụng
class AppSettingsSheet extends ConsumerWidget {
  const AppSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                      const Icon(Icons.settings_outlined, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text('Cài Đặt Ứng Dụng', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 1. Cài đặt thông báo
              Text('Thông Báo', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 6),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: settings.pushNotifications,
                  onChanged: (val) {
                    notifier.togglePushNotifications(val);
                    AppSnackBar.info(context, val ? 'Đã bật thông báo đơn hàng' : 'Đã tắt thông báo đơn hàng');
                  },
                  title: Text('Thông báo tiến trình đơn hàng', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                  subtitle: Text('Nhận cập nhật khi pha chế và giao hàng', style: AppTextStyles.caption),
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: settings.promoNotifications,
                  onChanged: (val) {
                    notifier.togglePromoNotifications(val);
                    AppSnackBar.info(context, val ? 'Đã bật thông báo ưu đãi' : 'Đã tắt thông báo ưu đãi');
                  },
                  title: Text('Thông báo ưu đãi & Voucher', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                  subtitle: Text('Không bỏ lỡ các mã giảm giá hấp dẫn trong ngày', style: AppTextStyles.caption),
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const Divider(height: 24, color: AppColors.lightBorder),

              // 2. Giao diện & Ngôn ngữ
              Text('Giao Diện & Hệ Thống', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 6),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: settings.isDarkMode,
                  onChanged: (val) {
                    notifier.toggleDarkMode(val);
                    AppSnackBar.info(context, val ? 'Đã chuyển sang giao diện Tối (Dark mode)' : 'Đã chuyển sang giao diện Sáng');
                  },
                  title: Text('Giao diện Tối (Dark mode)', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                  subtitle: Text('Giúp dịu mắt hơn khi sử dụng vào ban đêm', style: AppTextStyles.caption),
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Ngôn ngữ hiển thị', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                  trailing: DropdownButton<String>(
                    value: settings.language,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'Tiếng Việt', child: Text('🇻🇳 Tiếng Việt')),
                      DropdownMenuItem(value: 'English', child: Text('🇺🇸 English')),
                    ],
                    onChanged: (lang) {
                      if (lang != null) {
                        notifier.setLanguage(lang);
                        AppSnackBar.success(context, 'Đã chuyển ngôn ngữ sang $lang');
                      }
                    },
                  ),
                ),
              ),

              const Divider(height: 24, color: AppColors.lightBorder),

              // 3. Dọn dẹp bộ nhớ đệm
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Bộ nhớ đệm (Cache)', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                  subtitle: Text(
                    settings.cacheSizeMb > 0
                        ? 'Đang sử dụng ${settings.cacheSizeMb.toStringAsFixed(1)} MB'
                        : 'Bộ nhớ đệm đã được dọn sạch (0.0 MB)',
                    style: AppTextStyles.caption,
                  ),
                  trailing: TextButton.icon(
                    onPressed: settings.cacheSizeMb > 0
                        ? () {
                            notifier.clearCache();
                            AppSnackBar.success(context, '🧹 Đã dọn sạch bộ nhớ đệm thành công!');
                          }
                        : null,
                    icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                    label: const Text('Dọn dẹp'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
