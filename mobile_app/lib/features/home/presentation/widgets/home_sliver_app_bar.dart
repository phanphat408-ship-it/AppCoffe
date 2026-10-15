import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';

/// SliverAppBar dính (pinned: true) trên đỉnh màn hình kèm Thanh tìm kiếm và Icon Giỏ hàng
class HomeSliverAppBar extends StatelessWidget {
  final String? userName;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onMapTap;
  final bool isAuthenticated;
  final int cartItemCount;
  final String? locationText;

  const HomeSliverAppBar({
    super.key,
    this.userName,
    this.locationText,
    required this.searchController,
    required this.onSearchChanged,
    required this.onCartTap,
    required this.onProfileTap,
    this.onMapTap,
    this.isAuthenticated = false,
    this.cartItemCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black12,
      backgroundColor: AppColors.background,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,

      // 1. Tiêu đề: Lời chào và Vị trí giao hàng (Có thể bấm để mở Bản đồ)
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            userName != null && userName!.isNotEmpty
                ? 'Xin chào, $userName! 👋'
                : 'Cà phê & Đồ ăn sáng',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: onMapTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    locationText ?? 'Quận 1, TP. Hồ Chí Minh',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),

      // 2. Icon Bản đồ chi nhánh, Giỏ hàng và Nút Tài khoản
      actions: [
        if (onMapTap != null)
          IconButton(
            onPressed: onMapTap,
            tooltip: 'Bản đồ chi nhánh',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.r12),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: const Icon(
                Icons.map_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        IconButton(
          onPressed: onCartTap,
          tooltip: 'Giỏ hàng',
          icon: Badge(
            isLabelVisible: cartItemCount > 0,
            label: Text(cartItemCount > 99 ? '99+' : '$cartItemCount'),
            backgroundColor: AppColors.primary,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.r12),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: isAuthenticated ? 'Hồ sơ cá nhân' : 'Đăng nhập',
          onPressed: onProfileTap,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.r12),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Icon(
              isAuthenticated ? Icons.person_outline_rounded : Icons.login_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],

      // 3. Search Bar Pinned ở Bottom của SliverAppBar
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 10),
          color: AppColors.background,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.r16),
              border: Border.all(color: AppColors.lightBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Tìm món cà phê, trà, bánh ngọt...',
                      hintStyle: AppTextStyles.bodyMediumSecondary,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    color: AppColors.textSecondary,
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  ),
                Container(
                  margin: const EdgeInsets.all(5),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimens.r12),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
