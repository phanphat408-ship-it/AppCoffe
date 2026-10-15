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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '0909123456');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập thành công! Chào mừng bạn.'),
          backgroundColor: AppColors.success,
        ),
      );
      // Điều hướng vào màn hình Home
      context.go(AppRoutes.home);
    } else {
      final error = ref.read(authNotifierProvider).errorMessage ?? 'Đăng nhập thất bại.';
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
                const SizedBox(height: AppDimens.p32),

                // 1. Logo quán cà phê ở trên cùng
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppDimens.r20),
                    ),
                    child: const Icon(
                      Icons.coffee_rounded,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.p24),

                // 2. Tiêu đề (Sora Bold #313131)
                Center(
                  child: Text(
                    'Chào Mừng Trở Lại! ☕',
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppDimens.p8),
                Center(
                  child: Text(
                    'Đăng nhập để nhận ưu đãi và đặt món nhanh chóng',
                    style: AppTextStyles.bodyMediumSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppDimens.p16),

                // Tài khoản thử nghiệm nhanh (Hỗ trợ demo báo cáo đồ án)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimens.r12),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Demo:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _phoneController.text = '0909000001';
                                  _passwordController.text = 'Admin@123';
                                });
                              },
                              borderRadius: BorderRadius.circular(AppDimens.r8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE65100).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppDimens.r8),
                                  border: Border.all(color: const Color(0xFFE65100).withValues(alpha: 0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shield_rounded, size: 13, color: Color(0xFFE65100)),
                                    SizedBox(width: 4),
                                    Text(
                                      '👑 Admin (0909000001)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFE65100),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _phoneController.text = '0909123456';
                                  _passwordController.text = '123456';
                                });
                              },
                              borderRadius: BorderRadius.circular(AppDimens.r8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(AppDimens.r8),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_rounded, size: 13, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      '👤 Khách hàng',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.p16),

                // 3. Form Input với Validation
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
                      return 'Số điện thoại không đúng định dạng (10 chữ số)';
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

                const SizedBox(height: AppDimens.p12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Quên mật khẩu?',
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.p20),

                // 4. Primary Button (ElevatedButton bo góc tròn 16, nền #C67C4E)
                AppButton(
                  title: 'Đăng Nhập',
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: AppDimens.p16),

                // 5. TextButton chuyển đổi sang Đăng ký
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: AppTextStyles.bodyMediumSecondary,
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.register),
                        child: Text(
                          'Đăng ký ngay',
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.p12),

                // 6. Nút Khách vãng lai (Tiếp tục không đăng nhập)
                AppButton(
                  title: 'Xem Menu Ngay (Khách vãng lai)',
                  isOutlined: true,
                  onPressed: () => context.go(AppRoutes.home),
                ),

                const SizedBox(height: AppDimens.p32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
