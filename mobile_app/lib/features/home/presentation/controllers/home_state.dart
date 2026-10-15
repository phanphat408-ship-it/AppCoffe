import '../../data/models/banner_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

class HomeState {
  final List<CategoryModel> categories;
  final List<ProductModel> products;
  final List<BannerModel> banners;
  final int selectedCategoryId; // 0: Tất cả (All)
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.categories = const [],
    this.products = const [],
    this.banners = const [],
    this.selectedCategoryId = 0,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    List<CategoryModel>? categories,
    List<ProductModel>? products,
    List<BannerModel>? banners,
    int? selectedCategoryId,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      banners: banners ?? this.banners,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
