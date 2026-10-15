import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_models.dart';
import '../../data/repositories/order_repository.dart';
import 'cart_notifier.dart';

class CheckoutState {
  final bool isSubmitting;
  final String? errorMessage;

  const CheckoutState({this.isSubmitting = false, this.errorMessage});

  CheckoutState copyWith({bool? isSubmitting, String? errorMessage}) {
    return CheckoutState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

final checkoutNotifierProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);

/// Điều phối luồng Checkout: gom dữ liệu giỏ -> gọi `submitOrder()` -> dọn giỏ.
class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  /// Trả về [OrderResult] khi thành công, `null` khi thất bại
  /// (chi tiết lỗi nằm trong `state.errorMessage`).
  Future<OrderResult?> submitOrder() async {
    // 1. Chống double-tap: đang gửi thì bỏ qua mọi lần bấm tiếp theo
    if (state.isSubmitting) return null;

    // 2. Chụp (snapshot) dữ liệu giỏ tại thời điểm bấm "Đặt Hàng"
    final items = ref.read(cartNotifierProvider);
    if (items.isEmpty) {
      state = const CheckoutState(errorMessage: 'Giỏ hàng đang trống.');
      return null;
    }

    final note = ref.read(cartNoteProvider).trim();
    final request = OrderRequest(
      items: items,
      subtotal: ref.read(cartTotalProvider),
      deliveryFee: ref.read(deliveryFeeProvider),
      total: ref.read(cartGrandTotalProvider),
      note: note.isEmpty ? null : note,
    );

    state = const CheckoutState(isSubmitting: true);

    try {
      final result = await ref.read(orderRepositoryProvider).submitOrder(request);
      if (!ref.mounted) return result;

      // 3. Thành công -> làm trống giỏ & ghi chú
      ref.read(cartNotifierProvider.notifier).clearCart();
      ref.read(cartNoteProvider.notifier).clear();
      state = const CheckoutState();
      return result;
    } on OrderException catch (e) {
      if (ref.mounted) state = CheckoutState(errorMessage: e.message);
    } catch (_) {
      if (ref.mounted) {
        state = const CheckoutState(
          errorMessage: 'Đặt hàng thất bại. Vui lòng kiểm tra kết nối và thử lại.',
        );
      }
    }
    return null;
  }

  void clearError() {
    if (state.errorMessage != null) state = state.copyWith();
  }
}
