import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/branch_model.dart';

/// Card thông tin chi nhánh nổi ở phía dưới màn hình Bản đồ
class BranchInfoPanel extends StatelessWidget {
  final BranchModel branch;
  final bool isNearest;
  final VoidCallback? onClose;
  final VoidCallback? onDirectionsTap;
  final VoidCallback? onSelectBranch;

  const BranchInfoPanel({
    super.key,
    required this.branch,
    this.isNearest = false,
    this.onClose,
    this.onDirectionsTap,
    this.onSelectBranch,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r20),
        border: Border.all(
          color: isNearest ? AppColors.primary : AppColors.lightBorder,
          width: isNearest ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Huy hiệu Gần nhất & Nút đóng
          Row(
            children: [
              if (isNearest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimens.rFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Chi nhánh gần bạn nhất',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppDimens.rFull),
                  ),
                  child: Text(
                    'Chi nhánh được chọn',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Spacer(),
              if (onClose != null)
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(AppDimens.rFull),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Nội dung chi nhánh: Hình ảnh + Tên + Khoảng cách + Địa chỉ
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh chi nhánh
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.r12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: AppNetworkImage(
                    imageUrl: branch.imageUrl ?? '',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.storefront_rounded,
                    cacheWidth: 150,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Thông tin chi tiết
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      branch.address,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (branch.distanceInKm != null)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _InfoBadge(
                            icon: Icons.near_me_rounded,
                            label: branch.formattedDistance,
                            color: AppColors.primary,
                          ),
                          _InfoBadge(
                            icon: Icons.delivery_dining_rounded,
                            label: branch.formattedEta,
                            color: const Color(0xFFE8710A),
                          ),
                        ],
                      )
                    else if (branch.openingHours != null)
                      Text(
                        '🕒 ${branch.openingHours}',
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3. Action Buttons: Gọi điện + Chọn chi nhánh này
          Row(
            children: [
              if (onDirectionsTap != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDirectionsTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.r12),
                      ),
                    ),
                    icon: const Icon(Icons.navigation_rounded, color: AppColors.primary, size: 18),
                    label: Text(
                      'Xem trên bản đồ',
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              if (onDirectionsTap != null && onSelectBranch != null)
                const SizedBox(width: 10),
              if (onSelectBranch != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSelectBranch,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.r12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                    label: Text(
                      'Chọn đặt món',
                      style: AppTextStyles.button.copyWith(fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
}

/// Huy hiệu nhỏ hiển thị khoảng cách / thời gian giao dự kiến
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.r8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
