import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Dialog Đổi Mật Khẩu tài khoản
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final oldPass = _oldPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (oldPass.isEmpty) {
      AppSnackBar.error(context, 'Vui lòng nhập mật khẩu hiện tại');
      return;
    }
    if (newPass.length < 6) {
      AppSnackBar.error(context, 'Mật khẩu mới phải có ít nhất 6 ký tự');
      return;
    }
    if (newPass != confirmPass) {
      AppSnackBar.error(context, 'Mật khẩu xác nhận không trùng khớp');
      return;
    }

    Navigator.pop(context);
    AppSnackBar.success(context, '🔒 Đổi mật khẩu thành công! Hãy ghi nhớ mật khẩu mới.');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text('Đổi Mật Khẩu', style: AppTextStyles.h3.copyWith(fontSize: 17)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mật khẩu hiện tại
              AppTextField(
                label: 'Mật khẩu hiện tại',
                hintText: 'Nhập mật khẩu cũ',
                controller: _oldPassController,
                obscureText: _obscureOld,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
              ),
              const SizedBox(height: 12),

              // Mật khẩu mới
              AppTextField(
                label: 'Mật khẩu mới',
                hintText: 'Tối thiểu 6 ký tự',
                controller: _newPassController,
                obscureText: _obscureNew,
                prefixIcon: const Icon(Icons.key_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              const SizedBox(height: 12),

              // Xác nhận mật khẩu mới
              AppTextField(
                label: 'Xác nhận mật khẩu mới',
                hintText: 'Nhập lại mật khẩu mới',
                controller: _confirmPassController,
                obscureText: _obscureConfirm,
                prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 20),

              AppButton(
                title: 'Cập Nhật Mật Khẩu',
                onPressed: _handleSubmit,
                icon: const Icon(Icons.security_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
