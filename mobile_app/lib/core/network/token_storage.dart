import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider quản lý lưu trữ Token an toàn trong thiết bị
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});

class TokenStorage {
  static const String _keyToken = 'jwt_auth_token';
  static const String _keyRefreshToken = 'jwt_refresh_token';

  final FlutterSecureStorage _storage;

  TokenStorage(this._storage);

  /// Lưu JWT Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Lấy JWT Token đã lưu
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Xóa Token khi người dùng Đăng xuất (Logout)
  Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  /// Kiểm tra xem người dùng đã đăng nhập chưa
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
