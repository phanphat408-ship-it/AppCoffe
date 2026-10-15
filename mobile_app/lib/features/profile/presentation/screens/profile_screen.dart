import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../../cart/data/models/checkout_models.dart';
import '../../../orders/data/models/order_tracking_model.dart';
import '../../../orders/presentation/controllers/order_tracking_notifier.dart';
import '../controllers/favorites_notifier.dart';
import '../widgets/admin_menu_management_sheet.dart';
import '../widgets/admin_order_management_sheet.dart';
import '../widgets/admin_reports_sheet.dart';
import '../widgets/app_settings_sheet.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/favorite_products_sheet.dart';
import '../widgets/my_vouchers_sheet.dart';
import '../widgets/order_history_sheet.dart';
import '../widgets/saved_addresses_sheet.dart';
import '../widgets/support_center_sheet.dart';

/// Màn hình Hồ sơ cá nhân (Profile Screen) với Phân quyền Role-based UI và Khu vực Quản trị Admin
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    // Logic Phân Quyền (Role-based UI):
    // Người dùng là Admin khi role == 'Admin' hoặc SĐT đăng nhập là 0909000001
    final cleanPhone = user?.phone.replaceAll(RegExp(r'\D'), '') ?? '';
    final isAdmin = (user?.role.toLowerCase() == 'admin') || cleanPhone == '0909000001';

    final displayName = (user?.name != null && user!.name.isNotEmpty)
        ? user.name
        : (isAdmin ? 'Quản Trị Viên (Admin)' : 'Nguyễn Văn An');
    final displayPhone = (user?.phone != null && user!.phone.isNotEmpty)
        ? user.phone
        : (isAdmin ? '0909 000 001' : '0901 234 567');
    final displayAvatar = (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
        ? user.avatarUrl!
        : (isAdmin
            ? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500'
            : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500');

    final points = user?.points ?? 1250;
    final totalOrders = ref.watch(orderTrackingNotifierProvider).orders.length;
    final totalFavorites = ref.watch(favoritesProvider).length;
    final totalVouchers = VoucherModel.availableVouchers.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('Hồ Sơ Cá Nhân', style: AppTextStyles.h3),
        automaticallyImplyLeading: false,
        actions: [
          // Nút chuyển đổi nhanh vai trò phục vụ demo đồ án
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: Icon(
                isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                size: 16,
                color: isAdmin ? Colors.white : AppColors.primary,
              ),
              label: Text(
                isAdmin ? 'ADMIN' : 'KHÁCH',
                style: TextStyle(
                  color: isAdmin ? Colors.white : AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              backgroundColor: isAdmin ? const Color(0xFFE65100) : Colors.white,
              side: BorderSide(
                color: isAdmin ? const Color(0xFFE65100) : AppColors.primary,
              ),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).setDemoUser(isAdmin: !isAdmin);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      !isAdmin
                          ? '👑 Đã chuyển sang tài khoản Quản Trị Viên (0909000001)'
                          : '👤 Đã chuyển sang tài khoản Khách Hàng',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: !isAdmin ? const Color(0xFFE65100) : AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            // 1. Thẻ thông tin cá nhân: Avatar + Tên + SĐT + Nút Chỉnh sửa
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.r24),
                border: Border.all(
                  color: isAdmin
                      ? const Color(0xFFE65100).withValues(alpha: 0.3)
                      : AppColors.lightBorder,
                  width: isAdmin ? 1.5 : 1.0,
                ),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Column(
                children: [
                  // Avatar tròn với viền nổi bật
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isAdmin ? const Color(0xFFE65100) : AppColors.primary,
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
                          backgroundImage: ResizeImage(NetworkImage(displayAvatar), width: 400),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => EditProfileSheet.show(context),
                          borderRadius: BorderRadius.circular(AppDimens.rFull),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isAdmin ? const Color(0xFFE65100) : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Tên người dùng
                  Text(
                    displayName,
                    style: AppTextStyles.h3.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // Số điện thoại
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_iphone_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        displayPhone,
                        style: AppTextStyles.bodyMediumSecondary,
                      ),
                    ],
                  ),

                  // Huy hiệu Quản Trị Viên (Nếu là Admin)
                  if (isAdmin) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                        ),
                        borderRadius: BorderRadius.circular(AppDimens.rFull),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE65100).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'QUẢN TRỊ VIÊN HỆ THỐNG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Nút Chỉnh sửa hồ sơ
                  OutlinedButton.icon(
                    onPressed: () => EditProfileSheet.show(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isAdmin ? const Color(0xFFE65100) : AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.rFull),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    icon: Icon(
                      Icons.edit_note_rounded,
                      size: 18,
                      color: isAdmin ? const Color(0xFFE65100) : AppColors.primary,
                    ),
                    label: Text(
                      'Chỉnh sửa hồ sơ',
                      style: AppTextStyles.button.copyWith(
                        color: isAdmin ? const Color(0xFFE65100) : AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Yêu cầu 1: Ẩn đi thẻ "Aroma Coffee Rewards" khi là Admin
                  if (!isAdmin) ...[
                    const SizedBox(height: 16),
                    _buildRewardsCard(points),
                  ],
                ],
              ),
            ),

            // Yêu cầu 1 & 2: Chèn thêm danh mục mới nổi bật "⚙️ KHU VỰC QUẢN TRỊ CỬA HÀNG" ngay dưới phần thông tin cá nhân
            if (isAdmin) ...[
              const SizedBox(height: 18),
              _buildAdminSection(context, ref),
            ],

            const SizedBox(height: 18),

            // Thống kê nhanh: Đơn hàng | Yêu thích | Voucher
            Row(
              children: [
                Expanded(
                  child: _buildQuickStatCard(
                    title: 'Đơn hàng',
                    value: '$totalOrders',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF2E7D32),
                    onTap: () => OrderHistorySheet.show(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickStatCard(
                    title: 'Yêu thích',
                    value: '$totalFavorites',
                    icon: Icons.favorite_rounded,
                    color: AppColors.error,
                    onTap: () => FavoriteProductsSheet.show(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickStatCard(
                    title: 'Voucher',
                    value: '$totalVouchers',
                    icon: Icons.confirmation_num_rounded,
                    color: const Color(0xFFE65100),
                    onTap: () => MyVouchersSheet.show(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Yêu cầu 3: Đảm bảo các chức năng thông thường của khách hàng vẫn nằm ở phía dưới để Admin có thể test app
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.r20),
                border: Border.all(color: AppColors.lightBorder),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.receipt_long_rounded,
                    iconColor: const Color(0xFF2E7D32),
                    title: 'Lịch sử đơn hàng',
                    subtitle: 'Xem lại hóa đơn, trạng thái & đặt lại món',
                    onTap: () => OrderHistorySheet.show(context),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    iconColor: AppColors.primary,
                    title: 'Sổ địa chỉ giao hàng',
                    subtitle: 'Quản lý địa chỉ nhận hàng Nhà riêng & Công ty',
                    onTap: () => SavedAddressesSheet.show(context),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.favorite_border_rounded,
                    iconColor: AppColors.error,
                    title: 'Món ăn yêu thích',
                    subtitle: 'Danh sách các món bạn đã thả tim',
                    onTap: () => FavoriteProductsSheet.show(context),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.confirmation_num_outlined,
                    iconColor: const Color(0xFFE65100),
                    title: 'Kho Voucher / Ưu đãi của tôi',
                    subtitle: 'Mã giảm giá, Freeship & ưu đãi thành viên',
                    onTap: () => MyVouchersSheet.show(context),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.lock_outline_rounded,
                    iconColor: const Color(0xFF1976D2),
                    title: 'Đổi mật khẩu tài khoản',
                    subtitle: 'Bảo mật tài khoản cá nhân',
                    onTap: () => ChangePasswordDialog.show(context),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    iconColor: const Color(0xFF5D4037),
                    title: 'Cài đặt ứng dụng',
                    subtitle: 'Thông báo đẩy, giao diện Tối & dọn cache',
                    onTap: () => AppSettingsSheet.show(context),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.headset_mic_outlined,
                    iconColor: const Color(0xFF00796B),
                    title: 'Trung tâm hỗ trợ & Liên hệ',
                    subtitle: 'Hotline 1900 6868, FAQ & chính sách quán',
                    onTap: () => SupportCenterSheet.show(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nút ĐĂNG XUẤT
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.r16),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                label: Text(
                  'Đăng Xuất Tài Khoản',
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Aroma Coffee App • Phiên bản 2.5.0 Pro',
              style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  /// Giao diện Khu Vực Quản Trị Cửa Hàng (Yêu cầu 1 & 2)
  Widget _buildAdminSection(BuildContext context, WidgetRef ref) {
    final pendingCount = ref
        .watch(orderTrackingNotifierProvider)
        .orders
        .where((o) => o.currentStep == OrderStep.received)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r20),
        border: Border.all(
          color: const Color(0xFFE65100).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE65100).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner tiêu đề nổi bật "⚙️ KHU VỰC QUẢN TRỊ CỬA HÀNG"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C241E), Color(0xFF3E2723)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Color(0xFFFFD700),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '⚙️ KHU VỰC QUẢN TRỊ CỬA HÀNG',
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE65100),
                    borderRadius: BorderRadius.circular(AppDimens.rFull),
                  ),
                  child: const Text(
                    'QUẢN LÝ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3 Nút chức năng (ListTile) dành riêng cho quản lý:
          // 1. "📦 Quản lý Đơn hàng" (Duyệt đơn và cập nhật trạng thái)
          _buildAdminMenuItem(
            icon: Icons.inventory_2_rounded,
            iconColor: const Color(0xFF2E7D32),
            title: '📦 Quản lý Đơn hàng',
            subtitle: 'Duyệt đơn và cập nhật trạng thái',
            badgeText: pendingCount > 0 ? '$pendingCount chờ duyệt' : 'Hoạt động',
            badgeColor: pendingCount > 0 ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
            onTap: () => AdminOrderManagementSheet.show(context),
          ),
          const Divider(height: 1, indent: 56, color: AppColors.divider),

          // 2. "🍔 Quản lý Thực đơn" (Thêm/Sửa/Xóa/Ẩn món)
          _buildAdminMenuItem(
            icon: Icons.restaurant_menu_rounded,
            iconColor: const Color(0xFFE65100),
            title: '🍔 Quản lý Thực đơn',
            subtitle: 'Thêm/Sửa/Xóa/Ẩn món',
            badgeText: 'Thực đơn',
            badgeColor: const Color(0xFFE65100),
            onTap: () => AdminMenuManagementSheet.show(context),
          ),
          const Divider(height: 1, indent: 56, color: AppColors.divider),

          // 3. "📊 Thống kê & Báo cáo" (Xem doanh thu)
          _buildAdminMenuItem(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF1976D2),
            title: '📊 Thống kê & Báo cáo',
            subtitle: 'Xem doanh thu',
            badgeText: 'Doanh số',
            badgeColor: const Color(0xFF1976D2),
            onTap: () => AdminReportsSheet.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimens.r12),
          ),
          child: Icon(icon, color: iconColor, size: 21),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? iconColor).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.rFull),
                  border: Border.all(
                    color: (badgeColor ?? iconColor).withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor ?? iconColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildRewardsCard(int points) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C241E), Color(0xFF4A3E36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 22),
                  const SizedBox(width: 6),
                  Text(
                    'Aroma Coffee Rewards',
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimens.rFull),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1),
                ),
                child: const Text(
                  '👑 HẠNG VÀNG',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điểm tích lũy hiện tại',
                    style: AppTextStyles.caption.copyWith(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$points Điểm',
                    style: AppTextStyles.h3.copyWith(
                      color: const Color(0xFFFFD700),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                'Còn 750 điểm lên Kim Cương',
                style: AppTextStyles.caption.copyWith(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.rFull),
            child: const LinearProgressIndicator(
              value: 1250 / 2000,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.r16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.r16),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.subtitle.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimens.r12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(color: AppColors.textLight, fontSize: 11),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.r20),
        ),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 28),
        ),
        title: Text('Đăng Xuất', style: AppTextStyles.h3, textAlign: TextAlign.center),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?',
          style: AppTextStyles.bodyMediumSecondary,
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    side: const BorderSide(color: AppColors.lightBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.r12),
                    ),
                  ),
                  child: Text('Hủy', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.r12),
                    ),
                  ),
                  child: Text('Đăng Xuất', style: AppTextStyles.button.copyWith(fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }
}
