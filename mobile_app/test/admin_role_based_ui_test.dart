import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/token_storage.dart';
import 'package:mobile_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:mobile_app/features/orders/data/models/order_tracking_model.dart';
import 'package:mobile_app/features/orders/presentation/controllers/order_tracking_notifier.dart';
import 'package:mobile_app/features/profile/presentation/screens/profile_screen.dart';

class _FakeTokenStorage implements TokenStorage {
  String? _token;
  @override
  Future<void> saveToken(String token) async => _token = token;
  @override
  Future<String?> getToken() async => _token;
  @override
  Future<void> clearToken() async => _token = null;
  @override
  Future<bool> hasToken() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Panel & Role-based UI Tests', () {
    testWidgets('Giao diện Khách hàng: Có thẻ Aroma Coffee Rewards, không có Khu vực Quản trị',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        ],
      );

      // Thiết lập tài khoản Khách hàng
      container.read(authNotifierProvider.notifier).setDemoUser(isAdmin: false);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Dừng simulation timer để kết thúc test sạch sẽ
      container.read(orderTrackingNotifierProvider.notifier).pauseSimulation();

      // Kiểm tra có thẻ Rewards
      expect(find.text('Aroma Coffee Rewards'), findsOneWidget);
      expect(find.text('👑 HẠNG VÀNG'), findsOneWidget);

      // Không có khu vực quản trị
      expect(find.text('⚙️ KHU VỰC QUẢN TRỊ CỬA HÀNG'), findsNothing);
      expect(find.text('📦 Quản lý Đơn hàng'), findsNothing);
      expect(find.text('🍔 Quản lý Thực đơn'), findsNothing);
      expect(find.text('📊 Thống kê & Báo cáo'), findsNothing);

      // Có các tính năng thường của khách
      expect(find.text('Lịch sử đơn hàng'), findsOneWidget);
      expect(find.text('Sổ địa chỉ giao hàng'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Giao diện Admin (0909000001): Ẩn thẻ Rewards, hiển thị Khu Vực Quản Trị Cửa Hàng',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        ],
      );

      // Thiết lập tài khoản Admin với SĐT 0909000001
      container.read(authNotifierProvider.notifier).setDemoUser(isAdmin: true);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Dừng simulation timer để kết thúc test sạch sẽ
      container.read(orderTrackingNotifierProvider.notifier).pauseSimulation();

      // 1. Thẻ Aroma Coffee Rewards phải bị ẨN hoàn toàn
      expect(find.text('Aroma Coffee Rewards'), findsNothing);

      // 2. Hiển thị huy hiệu Admin và Khu vực Quản trị
      expect(find.text('QUẢN TRỊ VIÊN HỆ THỐNG'), findsOneWidget);
      expect(find.text('⚙️ KHU VỰC QUẢN TRỊ CỬA HÀNG'), findsOneWidget);

      // 3. Có đủ 3 nút chức năng quản trị
      expect(find.text('📦 Quản lý Đơn hàng'), findsOneWidget);
      expect(find.text('🍔 Quản lý Thực đơn'), findsOneWidget);
      expect(find.text('📊 Thống kê & Báo cáo'), findsOneWidget);

      // 4. Các chức năng thông thường của khách vẫn hiển thị ở phía dưới
      expect(find.text('Lịch sử đơn hàng'), findsOneWidget);
      expect(find.text('Sổ địa chỉ giao hàng'), findsOneWidget);
      expect(find.text('Đổi mật khẩu tài khoản'), findsOneWidget);

      container.dispose();
    });

    test('OrderTrackingNotifier hỗ trợ duyệt đơn updateOrderStep và addMockPendingOrder', () {
      final container = ProviderContainer();

      final notifier = container.read(orderTrackingNotifierProvider.notifier);
      notifier.pauseSimulation();

      final initialOrders = container.read(orderTrackingNotifierProvider).orders;
      expect(initialOrders.isNotEmpty, true);

      final targetOrder = initialOrders.first;
      expect(targetOrder.currentStep, OrderStep.received);

      // Admin duyệt đơn: Xác nhận & Pha chế
      notifier.updateOrderStep(targetOrder.orderCode, OrderStep.preparing);
      var currentOrders = container.read(orderTrackingNotifierProvider).orders;
      expect(
        currentOrders.firstWhere((o) => o.orderCode == targetOrder.orderCode).currentStep,
        OrderStep.preparing,
      );

      // Admin giao tài xế
      notifier.updateOrderStep(targetOrder.orderCode, OrderStep.delivering);
      currentOrders = container.read(orderTrackingNotifierProvider).orders;
      expect(
        currentOrders.firstWhere((o) => o.orderCode == targetOrder.orderCode).currentStep,
        OrderStep.delivering,
      );

      // Admin tạo đơn giả lập mới
      final prevCount = currentOrders.length;
      notifier.addMockPendingOrder();
      currentOrders = container.read(orderTrackingNotifierProvider).orders;
      expect(currentOrders.length, prevCount + 1);
      expect(currentOrders.first.currentStep, OrderStep.received);

      container.dispose();
    });
  });
}
