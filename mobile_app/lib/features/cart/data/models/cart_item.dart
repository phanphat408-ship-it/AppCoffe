import '../../../../core/utils/currency_formatter.dart';
import '../../../home/data/models/product_model.dart';

/// Một dòng món trong giỏ hàng (bất biến - immutable) có hỗ trợ tùy biến
/// Size (S/M/L), Mức đường, Mức đá, Toppings và Ghi chú riêng.
class CartItem {
  final String id;
  final ProductModel product;
  final int quantity;
  final String selectedSize;
  final int sizeExtraPrice;
  final String? selectedSugar;
  final String? selectedIce;
  final List<String> selectedToppings;
  final int toppingExtraPrice;
  final String? note;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedSize = 'Size M',
    this.sizeExtraPrice = 0,
    this.selectedSugar,
    this.selectedIce,
    this.selectedToppings = const [],
    this.toppingExtraPrice = 0,
    this.note,
  });

  int get productId => product.id;

  /// Đơn giá thực tế = Giá gốc sản phẩm + phụ phí size + phụ phí topping
  int get unitPrice => product.price.round() + sizeExtraPrice + toppingExtraPrice;

  /// Thành tiền của dòng = đơn giá x số lượng
  int get lineTotal => unitPrice * quantity;

  String get formattedUnitPrice => CurrencyFormatter.vnd(unitPrice);
  String get formattedLineTotal => CurrencyFormatter.vnd(lineTotal);

  /// Chuỗi tóm tắt cấu hình tùy chọn món (vd: "Size M • 70% đường • Ít đá • + Trân châu trắng")
  String get optionsSummary {
    final parts = <String>[];
    if (selectedSize.isNotEmpty) parts.add(selectedSize);
    if (selectedSugar != null && selectedSugar!.isNotEmpty) parts.add(selectedSugar!);
    if (selectedIce != null && selectedIce!.isNotEmpty) parts.add(selectedIce!);
    if (selectedToppings.isNotEmpty) {
      parts.add('+ ${selectedToppings.join(', ')}');
    }
    if (note != null && note!.trim().isNotEmpty) {
      parts.add('Note: "$note"');
    }
    return parts.join(' • ');
  }

  CartItem copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    String? selectedSize,
    int? sizeExtraPrice,
    String? selectedSugar,
    String? selectedIce,
    List<String>? selectedToppings,
    int? toppingExtraPrice,
    String? note,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      sizeExtraPrice: sizeExtraPrice ?? this.sizeExtraPrice,
      selectedSugar: selectedSugar ?? this.selectedSugar,
      selectedIce: selectedIce ?? this.selectedIce,
      selectedToppings: selectedToppings ?? this.selectedToppings,
      toppingExtraPrice: toppingExtraPrice ?? this.toppingExtraPrice,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem && other.id == id && other.quantity == quantity;

  @override
  int get hashCode => Object.hash(id, quantity);

  @override
  String toString() => 'CartItem(${product.name} [$optionsSummary] x$quantity)';
}
