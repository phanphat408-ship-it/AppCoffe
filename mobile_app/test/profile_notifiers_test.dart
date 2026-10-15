import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/token_storage.dart';
import 'package:mobile_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:mobile_app/features/home/data/models/product_model.dart';
import 'package:mobile_app/features/profile/presentation/controllers/app_settings_notifier.dart';
import 'package:mobile_app/features/profile/presentation/controllers/favorites_notifier.dart';
import 'package:mobile_app/features/profile/presentation/controllers/saved_addresses_notifier.dart';

class _FakeTokenStorage implements TokenStorage {
  String? _token = 'mock_jwt_token';

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  Future<bool> hasToken() async => _token != null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Notifiers Tests', () {
    test('SavedAddressesNotifier hỗ trợ thêm, sửa, xóa và đặt làm mặc định', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(savedAddressesProvider.notifier);
      final initialList = container.read(savedAddressesProvider);
      expect(initialList.length, 4);
      expect(initialList.first.isDefault, true);

      // 1. Thêm địa chỉ mới
      notifier.addAddress(
        title: 'Nhà bạn thân',
        recipientName: 'Trần Văn B',
        phone: '0988776655',
        fullAddress: '456 Điện Biên Phủ, Bình Thạnh',
        isDefault: false,
      );

      var list = container.read(savedAddressesProvider);
      expect(list.length, 5);
      final added = list.last;
      expect(added.title, 'Nhà bạn thân');
      expect(added.isDefault, false);

      // 2. Đặt làm mặc định
      notifier.setDefault(added.id);
      list = container.read(savedAddressesProvider);
      expect(list.firstWhere((a) => a.id == added.id).isDefault, true);
      expect(list.firstWhere((a) => a.id == 'addr_1').isDefault, false);

      // 3. Xóa địa chỉ
      notifier.deleteAddress(added.id);
      list = container.read(savedAddressesProvider);
      expect(list.length, 4);
      expect(list.any((a) => a.id == added.id), false);
    });

    test('FavoritesNotifier hỗ trợ bật/tắt và xóa món yêu thích', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);
      expect(container.read(favoritesProvider).isNotEmpty, true);

      const testProduct = ProductModel(
        id: 999,
        name: 'Trà Sữa Matcha Trân Châu',
        price: 50000,
        imageUrl: 'https://example.com/matcha.jpg',
        categoryId: 3,
      );

      // Chưa thích
      expect(notifier.isFavorite(999), false);

      // Bật thích
      notifier.toggleFavorite(testProduct);
      expect(notifier.isFavorite(999), true);
      expect(container.read(favoritesProvider).first.id, 999);

      // Bỏ thích qua toggle
      notifier.toggleFavorite(testProduct);
      expect(notifier.isFavorite(999), false);

      // Thêm lại rồi xóa qua removeFavorite
      notifier.toggleFavorite(testProduct);
      expect(notifier.isFavorite(999), true);
      notifier.removeFavorite(999);
      expect(notifier.isFavorite(999), false);
    });

    test('AppSettingsNotifier thay đổi cài đặt thông báo, dark mode và xóa cache', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appSettingsProvider.notifier);
      final initial = container.read(appSettingsProvider);

      expect(initial.pushNotifications, true);
      expect(initial.isDarkMode, false);
      expect(initial.language, 'Tiếng Việt');
      expect(initial.cacheSizeMb > 0, true);

      // Thay đổi
      notifier.togglePushNotifications(false);
      notifier.toggleDarkMode(true);
      notifier.setLanguage('English');
      notifier.clearCache();

      final updated = container.read(appSettingsProvider);
      expect(updated.pushNotifications, false);
      expect(updated.isDarkMode, true);
      expect(updated.language, 'English');
      expect(updated.cacheSizeMb, 0.0);
    });

    test('AuthNotifier.updateProfile cập nhật thành công thông tin người dùng trong state', () {
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        ],
      );
      addTearDown(container.dispose);

      final authNotifier = container.read(authNotifierProvider.notifier);

      authNotifier.updateProfile(
        name: 'Phan Hoàng Nam',
        phone: '0912 345 678',
        email: 'nam.phan@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final user = container.read(authNotifierProvider).user;
      expect(user != null, true);
      expect(user!.name, 'Phan Hoàng Nam');
      expect(user.phone, '0912 345 678');
      expect(user.email, 'nam.phan@example.com');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
    });
  });
}
