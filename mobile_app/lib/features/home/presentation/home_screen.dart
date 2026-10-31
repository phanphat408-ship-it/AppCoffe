import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/presentation/controllers/auth_notifier.dart';
import '../../branches/presentation/controllers/branch_notifier.dart';
import '../../cart/presentation/controllers/cart_notifier.dart';
import '../../main/presentation/screens/main_screen.dart';
import '../data/models/product_model.dart';
import 'controllers/home_notifier.dart';
import 'controllers/home_state.dart';
import 'widgets/home_banner_carousel.dart';
import 'widgets/home_category_list.dart';
import 'widgets/home_product_grid.dart';
import 'widgets/home_sliver_app_bar.dart';
import 'widgets/product_customization_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final userName = ref.watch(authNotifierProvider.select((s) => s.user?.name));
    final isAuthenticated = ref.watch(authNotifierProvider.select((s) => s.isAuthenticated));
    final locationText = ref.watch(branchNotifierProvider.select((s) => s.effectiveOrderBranch?.name));
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await ref.read(homeNotifierProvider.notifier).loadHomeData();
        },
        child: CustomScrollView(
          cacheExtent: 300,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. SliverAppBar (Pinned: Dính ở trên cùng với Search bar & Cart)
            HomeSliverAppBar(
              userName: userName,
              locationText: locationText,
              searchController: _searchController,
              isAuthenticated: isAuthenticated,
              cartItemCount: cartItemCount,
              onSearchChanged: (query) {
                ref.read(homeNotifierProvider.notifier).searchProducts(query);
              },
              onMapTap: () => context.push(AppRoutes.map),
              onCartTap: () => context.push(AppRoutes.cart),
              onProfileTap: () => _handleProfileTap(context, isAuthenticated),
            ),

            // 2. Banner Khuyến mãi tự động trượt (Carousel Slider)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 8),
                child: HomeBannerCarousel(
                  banners: homeState.banners,
                ),
              ),
            ),

            // 3. Tiêu đề mục Danh mục
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Danh Mục Món', style: AppTextStyles.subtitle),
                    Text(
                      'Xem tất cả',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Danh mục sản phẩm (Horizontal Category List)
            SliverToBoxAdapter(
              child: HomeCategoryList(
                categories: homeState.categories,
                selectedCategoryId: homeState.selectedCategoryId,
                onSelectCategory: (categoryId) {
                  ref.read(homeNotifierProvider.notifier).selectCategory(categoryId);
                },
              ),
            ),

            // 5. Tiêu đề mục Món ngon gợi ý
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getSectionTitle(homeState),
                      style: AppTextStyles.subtitle,
                    ),
                    Text(
                      '${homeState.products.length} món',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            // 6. Danh sách món ăn gợi ý (SliverGrid Product Cards)
            HomeProductGrid(
              products: homeState.products,
              isLoading: homeState.isLoading,
              onAddToCart: (product) => _openProductCustomization(product),
              onProductTap: (product) => _openProductCustomization(product),
            ),
          ],
        ),
      ),
    );
  }

  /// Mở BottomSheet tùy biến món (Size, Đá, Đường, Topping) chuẩn UX
  void _openProductCustomization(ProductModel product) {
    ProductCustomizationSheet.show(context, product);
  }

  String _getSectionTitle(HomeState homeState) {
    if (homeState.searchQuery.isNotEmpty) {
      return 'Kết quả cho: "${homeState.searchQuery}"';
    }
    if (homeState.selectedCategoryId == 0) {
      return 'Món Ngon Gợi Ý ⭐';
    }
    final category = homeState.categories
        .where((c) => c.id == homeState.selectedCategoryId)
        .firstOrNull;
    return category?.name ?? 'Món Ngon Gợi Ý';
  }

  void _handleProfileTap(BuildContext context, bool isAuthenticated) {
    if (isAuthenticated) {
      ref.read(mainTabIndexProvider.notifier).setTab(2);
    } else {
      context.go(AppRoutes.login);
    }
  }
}
