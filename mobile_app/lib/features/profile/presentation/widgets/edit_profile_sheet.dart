import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';

/// Danh sách avatar mẫu phong cách cho người dùng lựa chọn
const List<String> _kAvatarPresets = [
  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
  'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500',
  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500',
];

/// BottomSheet Chỉnh sửa thông tin cá nhân
class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileSheet(),
    );
  }

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _nameController = TextEditingController(text: user?.name ?? 'Nguyễn Văn An');
    _phoneController = TextEditingController(text: user?.phone ?? '0901234567');
    _emailController = TextEditingController(text: user?.email ?? 'nguyenvanan@gmail.com');
    _selectedAvatar = user?.avatarUrl ?? _kAvatarPresets[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      AppSnackBar.error(context, 'Họ và tên không được để trống');
      return;
    }
    if (phone.isEmpty) {
      AppSnackBar.error(context, 'Số điện thoại không được để trống');
      return;
    }

    ref.read(authNotifierProvider.notifier).updateProfile(
          name: name,
          phone: phone,
          email: email.isEmpty ? null : email,
          avatarUrl: _selectedAvatar,
        );

    Navigator.pop(context);
    AppSnackBar.success(context, '✨ Cập nhật hồ sơ cá nhân thành công!');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thanh kéo handle
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
                const SizedBox(height: 16),

                // Tiêu đề
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Chỉnh Sửa Hồ Sơ', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Chọn Avatar
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2.5),
                        ),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
                          backgroundImage: ResizeImage(NetworkImage(_selectedAvatar), width: 400),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Chọn ảnh đại diện của bạn', style: AppTextStyles.caption),
                      const SizedBox(height: 10),
                      // Preset avatars
                      SizedBox(
                        height: 52,
                        child: ListView.separated(
                          cacheExtent: 300,
                          addRepaintBoundaries: true,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: _kAvatarPresets.length,
                          separatorBuilder: (ctx, index) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final url = _kAvatarPresets[index];
                            final isSelected = url == _selectedAvatar;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedAvatar = url),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundImage: ResizeImage(NetworkImage(url), width: 150),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Họ và tên
                AppTextField(
                  label: 'Họ và tên',
                  hintText: 'Nhập họ và tên của bạn',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                const SizedBox(height: 14),

                // Số điện thoại
                AppTextField(
                  label: 'Số điện thoại',
                  hintText: 'Nhập số điện thoại',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_iphone_rounded),
                ),
                const SizedBox(height: 14),

                // Email
                AppTextField(
                  label: 'Email liên hệ',
                  hintText: 'Nhập email của bạn',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 24),

                // Nút Lưu thay đổi
                AppButton(
                  title: 'Lưu Thay Đổi',
                  onPressed: _handleSave,
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
