import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

class HomeNotifier extends Notifier<HomeState> {
  HomeRepository get _repository => ref.read(homeRepositoryProvider);

  @override
  HomeState build() {
    Future.microtask(() => loadHomeData());
    return const HomeState(isLoading: true);
  }

  /// Tải toàn bộ dữ liệu ban đầu cho Trang chủ (Banner, Categories, Products)
  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final banners = _repository.getBanners();
      final categories = await _repository.getCategories();
      final products = await _repository.getProducts(
        categoryId: state.selectedCategoryId > 0 ? state.selectedCategoryId : null,
        search: state.searchQuery,
      );

      state = state.copyWith(
        isLoading: false,
        banners: banners,
        categories: categories,
        products: products,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tải dữ liệu: $e',
      );
    }
  }

  /// Chọn danh mục sản phẩm (0: Tất cả, >0: CategoryId cụ thể)
  Future<void> selectCategory(int categoryId) async {
    if (state.selectedCategoryId == categoryId) return;

    state = state.copyWith(selectedCategoryId: categoryId, isLoading: true);

    final products = await _repository.getProducts(
      categoryId: categoryId > 0 ? categoryId : null,
      search: state.searchQuery,
    );

    state = state.copyWith(
      isLoading: false,
      products: products,
    );
  }

  /// Tìm kiếm sản phẩm theo từ khóa
  Future<void> searchProducts(String query) async {
    state = state.copyWith(searchQuery: query.trim(), isLoading: true);

    final products = await _repository.getProducts(
      categoryId: state.selectedCategoryId > 0 ? state.selectedCategoryId : null,
      search: query.trim(),
    );

    state = state.copyWith(
      isLoading: false,
      products: products,
    );
  }
}
