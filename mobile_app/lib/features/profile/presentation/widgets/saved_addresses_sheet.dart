import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/saved_address_model.dart';
import '../controllers/saved_addresses_notifier.dart';

/// BottomSheet Quản lý Sổ địa chỉ người dùng
class SavedAddressesSheet extends ConsumerWidget {
  const SavedAddressesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SavedAddressesSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(savedAddressesProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
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
                      const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text('Sổ Địa Chỉ Giao Hàng', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Danh sách địa chỉ
              Expanded(
                child: addresses.isEmpty
                    ? Center(
                        child: Text('Chưa có địa chỉ nào được lưu', style: AppTextStyles.caption),
                      )
                    : ListView.separated(
                        cacheExtent: 300,
                        addRepaintBoundaries: true,
                        itemCount: addresses.length,
                        separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = addresses[index];
                          return _buildAddressTile(context, ref, item);
                        },
                      ),
              ),

              const SizedBox(height: 16),

              // Nút Thêm địa chỉ mới
              AppButton(
                title: 'Thêm Địa Chỉ Mới',
                icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white, size: 20),
                onPressed: () => _showAddEditDialog(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTile(BuildContext context, WidgetRef ref, SavedAddress item) {
    final notifier = ref.read(savedAddressesProvider.notifier);

    return InkWell(
      onTap: () {
        if (!item.isDefault) {
          notifier.setDefault(item.id);
          AppSnackBar.success(context, 'Đã đặt "${item.title}" làm địa chỉ mặc định');
        }
      },
      borderRadius: BorderRadius.circular(AppDimens.r16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isDefault ? AppColors.primary.withValues(alpha: 0.05) : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimens.r16),
          border: Border.all(
            color: item.isDefault ? AppColors.primary : AppColors.lightBorder,
            width: item.isDefault ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.title.contains('Công ty')
                      ? Icons.business_rounded
                      : Icons.home_rounded,
                  color: item.isDefault ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  item.title,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                ),
                if (item.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimens.rFull),
                    ),
                    child: const Text(
                      'Mặc định',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                const Spacer(),
                // Nút sửa
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showAddEditDialog(context, ref, address: item),
                ),
                const SizedBox(width: 12),
                // Nút xóa
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _confirmDelete(context, ref, item),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${item.recipientName} • ${item.phone}',
              style: AppTextStyles.bodyMediumSecondary.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              item.fullAddress,
              style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontSize: 12.5),
            ),
            if (item.note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Ghi chú: ${item.note}',
                style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, SavedAddress item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa địa chỉ?'),
        content: Text('Bạn có chắc chắn muốn xóa địa chỉ "${item.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(savedAddressesProvider.notifier).deleteAddress(item.id);
      if (context.mounted) {
        AppSnackBar.success(context, 'Đã xóa địa chỉ thành công');
      }
    }
  }

  Future<void> _showAddEditDialog(BuildContext context, WidgetRef ref, {SavedAddress? address}) async {
    final isEditing = address != null;
    final titleCtrl = TextEditingController(text: address?.title ?? 'Nhà riêng');
    final nameCtrl = TextEditingController(text: address?.recipientName ?? 'Nguyễn Văn An');
    final phoneCtrl = TextEditingController(text: address?.phone ?? '0901234567');
    final addrCtrl = TextEditingController(text: address?.fullAddress ?? '');
    final noteCtrl = TextEditingController(text: address?.note ?? '');
    bool isDefault = address?.isDefault ?? false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.9,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditing ? 'Sửa Địa Chỉ' : 'Thêm Địa Chỉ Mới',
                            style: AppTextStyles.h3.copyWith(fontSize: 17),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Tên gợi nhớ (ví dụ: Nhà riêng, Công ty)',
                        controller: titleCtrl,
                        prefixIcon: const Icon(Icons.bookmark_border_rounded),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Họ và tên người nhận',
                        controller: nameCtrl,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Số điện thoại',
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_iphone_rounded),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Địa chỉ đầy đủ (Số nhà, đường, phường, quận)',
                        controller: addrCtrl,
                        maxLines: 2,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Ghi chú cho tài xế (Tùy chọn)',
                        controller: noteCtrl,
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                      ),
                      const SizedBox(height: 12),
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          value: isDefault,
                          onChanged: (val) => setSheetState(() => isDefault = val),
                          title: Text('Đặt làm địa chỉ mặc định', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                          activeThumbColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        title: isEditing ? 'Cập Nhật Địa Chỉ' : 'Lưu Địa Chỉ',
                        onPressed: () {
                          if (addrCtrl.text.trim().isEmpty) {
                            AppSnackBar.error(context, 'Vui lòng nhập địa chỉ đầy đủ');
                            return;
                          }
                          if (isEditing) {
                            ref.read(savedAddressesProvider.notifier).updateAddress(
                                  address.copyWith(
                                    title: titleCtrl.text.trim(),
                                    recipientName: nameCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim(),
                                    fullAddress: addrCtrl.text.trim(),
                                    note: noteCtrl.text.trim(),
                                    isDefault: isDefault,
                                  ),
                                );
                          } else {
                            ref.read(savedAddressesProvider.notifier).addAddress(
                                  title: titleCtrl.text.trim(),
                                  recipientName: nameCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                  fullAddress: addrCtrl.text.trim(),
                                  note: noteCtrl.text.trim(),
                                  isDefault: isDefault,
                                );
                          }
                          Navigator.pop(ctx);
                          AppSnackBar.success(context, 'Lưu địa chỉ thành công');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
