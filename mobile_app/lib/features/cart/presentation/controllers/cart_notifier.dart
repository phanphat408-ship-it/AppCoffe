import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/data/models/product_model.dart';
import '../../data/models/cart_item.dart';

// =============================================================================
// CẤU HÌNH GIỎ HÀNG
// =============================================================================

class CartConfig {
  CartConfig._();

  /// Số lượng tối đa cho 1 món (Backend cho phép 1..100)
  static const int maxQuantityPerItem = 99;

  /// Phí giao hàng cố định (Mock data)
  static const int deliveryFee = 15000;

  /// Độ dài tối đa của ghi chú (Backend cho phép 500)
  static const int maxNoteLength = 200;
}

/// Lỗi nghiệp vụ của giỏ hàng – UI bắt và hiển thị `message` cho người dùng.
class CartException implements Exception {
  final String message;
  const CartException(this.message);

  @override
  String toString() => message;
}

// =============================================================================
// CART NOTIFIER
// =============================================================================

final cartNotifierProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

/// Quản lý danh sách món trong giỏ hàng có hỗ trợ tùy chọn Size, Topping, Đường, Đá.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// Thêm [product] vào giỏ hàng với các tùy chọn.
  void addToCart(
    ProductModel product, [
    int quantity = 1,
    String selectedSize = 'Size M',
    int sizeExtraPrice = 0,
    String? selectedSugar,
    String? selectedIce,
    List<String> selectedToppings = const [],
    int toppingExtraPrice = 0,
    String? note,
  ]) {
    addCustomizedItem(
      product: product,
      quantity: quantity,
      selectedSize: selectedSize,
      sizeExtraPrice: sizeExtraPrice,
      selectedSugar: selectedSugar,
      selectedIce: selectedIce,
      selectedToppings: selectedToppings,
      toppingExtraPrice: toppingExtraPrice,
      note: note,
    );
  }

  /// Thêm món có tùy chọn đầy đủ vào giỏ hàng
  void addCustomizedItem({
    required ProductModel product,
    int quantity = 1,
    String selectedSize = 'Size M',
    int sizeExtraPrice = 0,
    String? selectedSugar,
    String? selectedIce,
    List<String> selectedToppings = const [],
    int toppingExtraPrice = 0,
    String? note,
  }) {
    if (quantity <= 0) {
      throw const CartException('Số lượng thêm vào phải lớn hơn 0.');
    }
    if (!product.isAvailable) {
      throw CartException('"${product.name}" hiện đã hết hàng.');
    }
    if (product.price <= 0) {
      throw CartException('Giá của "${product.name}" không hợp lệ.');
    }

    final cleanToppings = [...selectedToppings]..sort();
    final itemId = _buildItemId(
      product.id,
      selectedSize,
      selectedSugar,
      selectedIce,
      cleanToppings,
      note,
    );

    final index = state.indexWhere((item) => item.id == itemId);
    final currentQty = index == -1 ? 0 : state[index].quantity;
    final newQty = currentQty + quantity;

    if (newQty > CartConfig.maxQuantityPerItem) {
      throw const CartException(
        'Mỗi cấu hình món chỉ được đặt tối đa ${CartConfig.maxQuantityPerItem} phần.',
      );
    }

    if (index == -1) {
      final newItem = CartItem(
        id: itemId,
        product: product,
        quantity: quantity,
        selectedSize: selectedSize,
        sizeExtraPrice: sizeExtraPrice,
        selectedSugar: selectedSugar,
        selectedIce: selectedIce,
        selectedToppings: cleanToppings,
        toppingExtraPrice: toppingExtraPrice,
        note: note,
      );
      state = List.unmodifiable([...state, newItem]);
    } else {
      _replaceAt(index, state[index].copyWith(quantity: newQty));
    }
  }

  /// Xóa hẳn một món khỏi giỏ theo itemId (String) hoặc productId (int/String)
  void removeFromCart(Object itemId) {
    final idStr = itemId.toString();
    if (!state.any((item) => item.id == idStr || item.productId.toString() == idStr)) return;
    state = List.unmodifiable(
      state.where((item) => item.id != idStr && item.productId.toString() != idStr),
    );
  }

  /// Cập nhật số lượng của một dòng món trong giỏ theo itemId (String) hoặc productId (int/String)
  void updateQuantity(Object itemId, int newQuantity) {
    final idStr = itemId.toString();
    final index = state.indexWhere((item) => item.id == idStr || item.productId.toString() == idStr);
    if (index == -1) {
      throw const CartException('Món này không còn trong giỏ hàng.');
    }
    if (newQuantity < 0) {
      throw const CartException('Số lượng không được âm.');
    }
    if (newQuantity > CartConfig.maxQuantityPerItem) {
      throw const CartException(
        'Mỗi món chỉ được đặt tối đa ${CartConfig.maxQuantityPerItem} phần.',
      );
    }

    if (newQuantity == 0) {
      removeFromCart(state[index].id);
      return;
    }
    if (state[index].quantity == newQuantity) return;

    _replaceAt(index, state[index].copyWith(quantity: newQuantity));
  }

  /// Làm trống giỏ hàng
  void clearCart() {
    if (state.isEmpty) return;
    state = const [];
  }

  /// Tổng số lượng của một món trong giỏ (tính gộp các size/tùy chọn)
  int quantityOf(int productId) {
    return state
        .where((item) => item.productId == productId)
        .fold<int>(0, (sum, item) => sum + item.quantity);
  }

  // ---------------------------------------------------------------------------
  static String _buildItemId(
    int productId,
    String size,
    String? sugar,
    String? ice,
    List<String> toppings,
    String? note,
  ) {
    return '${productId}_${size}_${sugar ?? ""}_${ice ?? ""}_${toppings.join("-")}_${note?.trim() ?? ""}';
  }

  void _replaceAt(int index, CartItem item) {
    final updated = [...state];
    updated[index] = item;
    state = List.unmodifiable(updated);
  }
}

// =============================================================================
// DERIVED PROVIDERS (tự động tính lại khi giỏ hàng thay đổi)
// =============================================================================

/// Tổng tiền món (chưa gồm phí ship)
final cartTotalProvider = Provider<int>((ref) {
  final items = ref.watch(cartNotifierProvider);
  return items.fold<int>(0, (sum, item) => sum + item.lineTotal);
});

/// Tổng số phần (dùng cho Badge giỏ hàng)
final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartNotifierProvider);
  return items.fold<int>(0, (sum, item) => sum + item.quantity);
});

/// Phí giao hàng – 0đ khi giỏ trống
final deliveryFeeProvider = Provider<int>((ref) {
  final isEmpty = ref.watch(cartNotifierProvider).isEmpty;
  return isEmpty ? 0 : CartConfig.deliveryFee;
});

/// Tổng thanh toán = Tổng tiền món + Phí giao hàng
final cartGrandTotalProvider = Provider<int>((ref) {
  return ref.watch(cartTotalProvider) + ref.watch(deliveryFeeProvider);
});

// =============================================================================
// GHI CHÚ ĐƠN HÀNG
// =============================================================================

final cartNoteProvider = NotifierProvider<CartNoteNotifier, String>(CartNoteNotifier.new);

/// Lưu ghi chú chung cho toàn bộ đơn hàng
class CartNoteNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setNote(String value) {
    final trimmed = value.length > CartConfig.maxNoteLength
        ? value.substring(0, CartConfig.maxNoteLength)
        : value;
    state = trimmed;
  }

  void clear() => state = '';
}
