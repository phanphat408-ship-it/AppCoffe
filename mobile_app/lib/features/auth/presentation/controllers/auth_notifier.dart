import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/token_storage.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// NotifierProvider quản lý trạng thái Xác thực toàn ứng dụng
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);
  TokenStorage get _tokenStorage => ref.read(tokenStorageProvider);

  @override
  AuthState build() {
    // Khởi chạy kiểm tra Token bất đồng bộ ngay khi Notifier được tạo
    Future.microtask(() => checkAuthStatus());
    return const AuthState();
  }

  /// Kiểm tra trạng thái đăng nhập khi ứng dụng khởi chạy
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      // Gọi API lấy thông tin người dùng với Token hiện tại
      final user = await _repository.getCurrentUser();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: token,
        user: user,
      );
    } catch (_) {
      // Nếu token hết hạn hoặc Backend không xác thực được
      await _tokenStorage.clearToken();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        token: null,
        user: null,
      );
    }
  }

  /// Xử lý Đăng nhập (Login)
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final authResponse = await _repository.login(
        phone: phone,
        password: password,
      );

      // Lưu Token vào Secure Storage
      await _tokenStorage.saveToken(authResponse.token);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: authResponse.token,
        user: authResponse.user,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Xử lý Đăng ký (Register)
  Future<bool> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final authResponse = await _repository.register(
        name: name,
        phone: phone,
        password: password,
      );

      // Lưu Token vào Secure Storage ngay sau khi đăng ký thành công
      await _tokenStorage.saveToken(authResponse.token);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: authResponse.token,
        user: authResponse.user,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Cập nhật thông tin người dùng trong ứng dụng
  void updateProfile({
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
  }) {
    final currentUser = state.user ??
        const UserModel(
          id: 1,
          name: 'Nguyễn Văn An',
          phone: '0901 234 567',
          role: 'Customer',
        );

    final updatedUser = currentUser.copyWith(
      name: name,
      phone: phone,
      email: email,
      avatarUrl: avatarUrl,
    );
    state = state.copyWith(user: updatedUser);
  }

  /// Đăng xuất (Logout)
  Future<void> logout() async {
    await _tokenStorage.clearToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
