import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/utils/currency_formatter.dart';
import 'package:mobile_app/features/cart/data/models/order_models.dart';
import 'package:mobile_app/features/cart/data/repositories/order_repository.dart';
import 'package:mobile_app/features/cart/presentation/controllers/cart_notifier.dart';
import 'package:mobile_app/features/cart/presentation/controllers/checkout_notifier.dart';
import 'package:mobile_app/features/home/data/models/product_model.dart';

const _latte = ProductModel(
  id: 1,
  name: 'Latte',
  price: 45000,
  imageUrl: '',
  categoryId: 1,
);
const _tea = ProductModel(
  id: 2,
  name: 'Trà Đào',
  price: 39000,
  imageUrl: '',
  categoryId: 2,
);
const _soldOut = ProductModel(
  id: 3,
  name: 'Bạc Xỉu',
  price: 30000,
  imageUrl: '',
  categoryId: 1,
  isAvailable: false,
);

/// Mock repo cho test – không có độ trễ, có thể giả lập lỗi
class _FakeOrderRepository implements OrderRepository {
  final bool shouldFail;
  OrderRequest? lastRequest;
  int callCount = 0;

  _FakeOrderRepository({this.shouldFail = false});

  @override
  Future<OrderResult> submitOrder(OrderRequest request) async {
    callCount++;
    lastRequest = request;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (shouldFail) throw const OrderException('Quán đang quá tải');
    return OrderResult(
      orderCode: 'TEST01',
      totalAmount: request.total,
      totalQuantity: request.totalQuantity,
      createdAt: DateTime(2026),
    );
  }

  @override
  Future<bool> updateOrderStatus(int orderId, String status) async {
    return true;
  }
}

void main() {
  late ProviderContainer container;
  CartNotifier cart() => container.read(cartNotifierProvider.notifier);

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  group('CurrencyFormatter', () {
    test('định dạng VNĐ chuẩn', () {
      expect(CurrencyFormatter.vnd(0), '0 đ');
      expect(CurrencyFormatter.vnd(500), '500 đ');
      expect(CurrencyFormatter.vnd(15000), '15.000 đ');
      expect(CurrencyFormatter.vnd(1234567), '1.234.567 đ');
      expect(CurrencyFormatter.vnd(-15000), '-15.000 đ');
    });
  });

  group('CartNotifier.addToCart', () {
    test('thêm món mới & cộng dồn khi trùng món (không tạo dòng trùng)', () {
      cart().addToCart(_latte);
      cart().addToCart(_latte, 2);
      cart().addToCart(_tea);

      final items = container.read(cartNotifierProvider);
      expect(items.length, 2);
      expect(items.first.quantity, 3);
    });

    test('từ chối số lượng <= 0, món hết hàng, vượt giới hạn', () {
      expect(() => cart().addToCart(_latte, 0), throwsA(isA<CartException>()));
      expect(() => cart().addToCart(_latte, -1), throwsA(isA<CartException>()));
      expect(() => cart().addToCart(_soldOut), throwsA(isA<CartException>()));

      cart().addToCart(_latte, CartConfig.maxQuantityPerItem);
      expect(() => cart().addToCart(_latte), throwsA(isA<CartException>()));
      expect(cart().quantityOf(_latte.id), CartConfig.maxQuantityPerItem);
    });

    test('state là danh sách bất biến', () {
      cart().addToCart(_latte);
      final items = container.read(cartNotifierProvider);
      expect(() => items.add(items.first), throwsUnsupportedError);
    });
  });

  group('CartNotifier.updateQuantity / removeFromCart / clearCart', () {
    test('cập nhật số lượng & về 0 thì xóa món', () {
      cart().addToCart(_latte);
      cart().updateQuantity(_latte.id, 5);
      expect(cart().quantityOf(_latte.id), 5);

      cart().updateQuantity(_latte.id, 0);
      expect(container.read(cartNotifierProvider), isEmpty);
    });

    test('từ chối số âm, vượt giới hạn, món không có trong giỏ', () {
      cart().addToCart(_latte);
      expect(() => cart().updateQuantity(_latte.id, -1), throwsA(isA<CartException>()));
      expect(
        () => cart().updateQuantity(_latte.id, CartConfig.maxQuantityPerItem + 1),
        throwsA(isA<CartException>()),
      );
      expect(() => cart().updateQuantity(999, 1), throwsA(isA<CartException>()));
    });

    test('removeFromCart idempotent & clearCart làm trống giỏ', () {
      cart().addToCart(_latte);
      cart().addToCart(_tea);
      cart().removeFromCart(_latte.id);
      cart().removeFromCart(_latte.id); // không lỗi
      expect(container.read(cartNotifierProvider).length, 1);

      cart().clearCart();
      expect(container.read(cartNotifierProvider), isEmpty);
    });
  });

  group('Derived providers', () {
    test('tự động tính tổng tiền, số phần, phí ship, tổng thanh toán', () {
      expect(container.read(cartTotalProvider), 0);
      expect(container.read(deliveryFeeProvider), 0); // giỏ trống: không phí ship
      expect(container.read(cartGrandTotalProvider), 0);

      cart().addToCart(_latte, 2); // 90.000
      cart().addToCart(_tea); //      39.000

      expect(container.read(cartTotalProvider), 129000);
      expect(container.read(cartItemCountProvider), 3);
      expect(container.read(deliveryFeeProvider), CartConfig.deliveryFee);
      expect(container.read(cartGrandTotalProvider), 144000);

      cart().updateQuantity(_latte.id, 1);
      expect(container.read(cartGrandTotalProvider), 45000 + 39000 + 15000);
    });
  });

  group('CheckoutNotifier.submitOrder', () {
    test('thành công: gửi đúng payload, clearCart & xóa ghi chú', () async {
      final repo = _FakeOrderRepository();
      container.dispose();
      container = ProviderContainer(
        overrides: [orderRepositoryProvider.overrideWithValue(repo)],
      );

      cart().addToCart(_latte, 2);
      container.read(cartNoteProvider.notifier).setNote('  Ít đá  ');

      final result = await container.read(checkoutNotifierProvider.notifier).submitOrder();

      expect(result, isNotNull);
      expect(result!.totalAmount, 105000);
      expect(repo.lastRequest!.note, 'Ít đá');
      expect(repo.lastRequest!.toJson()['items'], [
        {'productId': 1, 'quantity': 2},
      ]);
      expect(container.read(cartNotifierProvider), isEmpty);
      expect(container.read(cartNoteProvider), '');
      expect(container.read(checkoutNotifierProvider).isSubmitting, isFalse);
    });

    test('chống double-tap: bấm 2 lần chỉ gửi 1 đơn', () async {
      final repo = _FakeOrderRepository();
      container.dispose();
      container = ProviderContainer(
        overrides: [orderRepositoryProvider.overrideWithValue(repo)],
      );
      cart().addToCart(_latte);

      final checkout = container.read(checkoutNotifierProvider.notifier);
      final results = await Future.wait([checkout.submitOrder(), checkout.submitOrder()]);

      expect(repo.callCount, 1);
      expect(results.whereType<OrderResult>().length, 1);
    });

    test('giỏ trống: không gọi API, trả lỗi', () async {
      final repo = _FakeOrderRepository();
      container.dispose();
      container = ProviderContainer(
        overrides: [orderRepositoryProvider.overrideWithValue(repo)],
      );

      final result = await container.read(checkoutNotifierProvider.notifier).submitOrder();
      expect(result, isNull);
      expect(repo.callCount, 0);
      expect(container.read(checkoutNotifierProvider).errorMessage, isNotNull);
    });

    test('API lỗi: giữ nguyên giỏ hàng để người dùng thử lại', () async {
      container.dispose();
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(_FakeOrderRepository(shouldFail: true)),
        ],
      );
      cart().addToCart(_latte);

      final result = await container.read(checkoutNotifierProvider.notifier).submitOrder();
      expect(result, isNull);
      expect(container.read(cartNotifierProvider).length, 1);
      expect(container.read(checkoutNotifierProvider).errorMessage, 'Quán đang quá tải');
    });
  });
}
