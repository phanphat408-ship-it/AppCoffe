import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/orders/data/models/order_tracking_model.dart';
import 'package:mobile_app/features/orders/presentation/controllers/order_tracking_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('OrderTrackingModel & Steps Tests', () {
    test('OrderStep có đủ 4 bước chuẩn với title và subtitle', () {
      expect(OrderStep.values.length, 4);
      expect(OrderStep.received.title, 'Đã nhận đơn');
      expect(OrderStep.preparing.title, 'Quán đang pha chế');
      expect(OrderStep.delivering.title, 'Tài xế đang giao');
      expect(OrderStep.completed.title, 'Hoàn tất');
    });

    test('TrackedOrder copyWith hoạt động chính xác', () {
      final initial = TrackedOrder(
        orderCode: 'TEST01',
        orderTime: DateTime(2026),
        branchName: 'Chi nhánh Test',
        deliveryAddress: 'Địa chỉ Test',
        items: const [],
        totalAmount: 50000,
        currentStep: OrderStep.received,
        estimatedDeliveryTime: '20 phút',
      );

      final updated = initial.copyWith(currentStep: OrderStep.delivering);
      expect(updated.currentStep, OrderStep.delivering);
      expect(updated.orderCode, 'TEST01');
    });
  });

  group('OrderTrackingNotifier Tests', () {
    test('Khởi tạo state với 2 đơn hàng mẫu và bắt đầu ở bước received', () {
      final state = container.read(orderTrackingNotifierProvider);
      expect(state.orders.length, 2);

      final active = state.activeOrder;
      expect(active, isNotNull);
      expect(active!.orderCode, 'CF82914');
      expect(active.currentStep, OrderStep.received);
      expect(state.isSimulating, isFalse);
    });

    test('advanceStep() nhảy tuần tự qua 4 bước và quay vòng lặp', () {
      final notifier = container.read(orderTrackingNotifierProvider.notifier);

      // Bước 0 -> 1: Quán đang pha chế
      notifier.advanceStep();
      expect(
        container.read(orderTrackingNotifierProvider).activeOrder?.currentStep,
        OrderStep.preparing,
      );

      // Bước 1 -> 2: Tài xế đang giao
      notifier.advanceStep();
      expect(
        container.read(orderTrackingNotifierProvider).activeOrder?.currentStep,
        OrderStep.delivering,
      );

      // Bước 2 -> 3: Hoàn tất
      notifier.advanceStep();
      expect(
        container.read(orderTrackingNotifierProvider).activeOrder?.currentStep,
        OrderStep.completed,
      );

      // Bước 3 -> 0: Quay lại Đã nhận đơn (vòng lặp demo mượt mà)
      notifier.advanceStep();
      expect(
        container.read(orderTrackingNotifierProvider).activeOrder?.currentStep,
        OrderStep.received,
      );
    });

    test('updateOrderStep cập nhật trạng thái đơn hàng thủ công của Admin', () {
      final notifier = container.read(orderTrackingNotifierProvider.notifier);

      notifier.updateOrderStep('CF82914', OrderStep.preparing);
      expect(
        container.read(orderTrackingNotifierProvider).activeOrder?.currentStep,
        OrderStep.preparing,
      );

      notifier.updateOrderStep('CF82914', OrderStep.delivering);
      expect(
        container.read(orderTrackingNotifierProvider).activeOrder?.currentStep,
        OrderStep.delivering,
      );
    });

    test('setStep đặt trực tiếp bước chỉ định', () {
      final notifier = container.read(orderTrackingNotifierProvider.notifier);

      notifier.setStep(OrderStep.delivering);
      expect(
        container.read(orderTrackingNotifierProvider).activeOrder?.currentStep,
        OrderStep.delivering,
      );
    });
  });
}
