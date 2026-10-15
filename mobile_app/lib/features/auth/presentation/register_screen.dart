import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'controllers/auth_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).register(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký tài khoản thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
      // Điều hướng vào màn hình Home
      context.go(AppRoutes.home);
    } else {
      final error = ref.read(authNotifierProvider).errorMessage ?? 'Đăng ký thất bại.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimens.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimens.p24),

                // 1. Logo quán cà phê ở trên cùng
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppDimens.r20),
                    ),
                    child: const Icon(
                      Icons.coffee_rounded,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.p20),

                // 2. Tiêu đề (Sora Bold #313131)
                Center(
                  child: Text(
                    'Tạo Tài Khoản Mới ✨',
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppDimens.p8),
                Center(
                  child: Text(
                    'Đăng ký để tích điểm và nhận ưu đãi mỗi ngày',
                    style: AppTextStyles.bodyMediumSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppDimens.p24),

                // 3. Các ô nhập liệu có Form Validation
                AppTextField(
                  label: 'Họ và tên',
                  hintText: 'Nhập họ và tên của bạn',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    if (value.trim().length < 2) {
                      return 'Họ tên phải có ít nhất 2 ký tự';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimens.p16),

                AppTextField(
                  label: 'Số điện thoại',
                  hintText: 'Nhập số điện thoại (vd: 0909123456)',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
                    if (!phoneRegex.hasMatch(value.trim())) {
                      return 'Số điện thoại không đúng định dạng (10 số)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimens.p16),

                AppTextField(
                  label: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu (tối thiểu 6 ký tự)',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải dài hơn 6 ký tự';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimens.p16),

                AppTextField(
                  label: 'Xác nhận mật khẩu',
                  hintText: 'Nhập lại mật khẩu',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu xác nhận không trùng khớp';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimens.p24),

                // 4. Nút ElevatedButton bo góc tròn 16, nền Primary #C67C4E
                AppButton(
                  title: 'Đăng Ký Tài Khoản',
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),

                const SizedBox(height: AppDimens.p16),

                // 5. TextButton chuyển đổi sang Đăng nhập
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: AppTextStyles.bodyMediumSecondary,
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: Text(
                          'Đăng nhập ngay',
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.p24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
