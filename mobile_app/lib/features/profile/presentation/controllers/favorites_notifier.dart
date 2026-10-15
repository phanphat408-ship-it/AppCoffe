import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/data/models/product_model.dart';

/// Provider quản lý danh sách Món ăn yêu thích
final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<ProductModel>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends Notifier<List<ProductModel>> {
  @override
  List<ProductModel> build() {
    return const [
      ProductModel(
        id: 1,
        name: 'Cà Phê Sữa Đá Sài Gòn',
        description: 'Đậm đà phong vị cà phê Robusta rang xay mộc hòa quyện cùng sữa đặc béo ngậy.',
        price: 29000,
        imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
        categoryId: 1,
        categoryName: 'Cà Phê Việt',
        rating: 4.9,
        isBestSeller: true,
      ),
      ProductModel(
        id: 7,
        name: 'Trà Đào Cam Sả Tươi Mát',
        description: 'Vị trà thanh mát kết hợp lát đào giòn ngọt sần sật, nước cam tươi và hương sả thơm lừng.',
        price: 45000,
        imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
        categoryId: 2,
        categoryName: 'Trà Trái Cây & Trà Sữa',
        rating: 4.9,
      ),
      ProductModel(
        id: 19,
        name: 'Bánh Sừng Trâu Croissant Bơ Pháp',
        description: 'Bánh ngàn lớp thơm lừng bơ Pháp cao cấp, vỏ ngoài giòn tan, ruột mềm thơm ngọt dịu.',
        price: 35000,
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80',
        categoryId: 4,
        categoryName: 'Bánh Ngọt & Ăn Vặt',
        rating: 4.8,
      ),
    ];
  }

  /// Kiểm tra xem món có trong danh sách yêu thích hay không
  bool isFavorite(int productId) {
    return state.any((p) => p.id == productId);
  }

  /// Bật/tắt trạng thái yêu thích
  void toggleFavorite(ProductModel product) {
    if (isFavorite(product.id)) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [product, ...state];
    }
  }

  /// Xóa khỏi danh sách yêu thích
  void removeFavorite(int productId) {
    state = state.where((p) => p.id != productId).toList();
  }
}
