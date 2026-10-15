import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return HomeRepository(dio);
});

class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  /// Lấy danh sách danh mục (API với Fallback Dummy Data)
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.categories,
        options: Options(extra: {'requiresAuth': false}),
      );

      final responseData = response.data as Map<String, dynamic>;
      final success = responseData['success'] as bool? ?? false;

      if (success && responseData['data'] is List) {
        final list = responseData['data'] as List;
        final categories = list
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (categories.isNotEmpty) {
          return categories;
        }
      }
    } catch (e) {
      debugPrint('>> API Categories failed or offline. Sử dụng Dummy Data mẫu: $e');
    }

    // Fallback Dummy Categories
    return _dummyCategories;
  }

  /// Lấy danh sách sản phẩm (API với Filter & Fallback Dummy Data)
  Future<List<ProductModel>> getProducts({int? categoryId, String? search}) async {
    try {
      final queryParams = <String, dynamic>{
        'onlyAvailable': true,
      };
      if (categoryId != null && categoryId > 0) {
        queryParams['categoryId'] = categoryId;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _dio.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
        options: Options(extra: {'requiresAuth': false}),
      );

      final responseData = response.data as Map<String, dynamic>;
      final success = responseData['success'] as bool? ?? false;

      if (success && responseData['data'] is List) {
        final list = responseData['data'] as List;
        return list
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('>> API Products failed or offline. Sử dụng Dummy Data mẫu: $e');
    }

    // Fallback Dummy Products có lọc theo category và search
    var results = List<ProductModel>.from(_dummyProducts);

    if (categoryId != null && categoryId > 0) {
      results = results.where((p) => p.categoryId == categoryId).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      results = results
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              (p.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    return results;
  }

  /// Danh sách Banner khuyến mãi
  List<BannerModel> getBanners() {
    return const [
      BannerModel(
        id: 1,
        tag: 'Ưu Đãi Đặc Biệt',
        title: 'Mua 1 Tặng 1\nMỗi Sáng Thứ 2',
        subtitle: 'Áp dụng cho toàn bộ menu Cà phê Việt',
        icon: Icons.local_cafe_rounded,
        startColor: Color(0xFF222222),
        endColor: Color(0xFF383838),
      ),
      BannerModel(
        id: 2,
        tag: 'Món Mới Ra Mắt',
        title: 'Trà Sữa Oolong\nNướng Macchiato',
        subtitle: 'Giảm 20% cho thành viên mới',
        icon: Icons.bubble_chart_rounded,
        startColor: AppColors.primary,
        endColor: Color(0xFF8F4D25),
      ),
      BannerModel(
        id: 3,
        tag: 'Combo Bữa Sáng',
        title: 'Cà Phê Sữa Đá +\nCroissant Bơ Pháp',
        subtitle: 'Chỉ 49.000đ từ 7:00 - 10:00',
        icon: Icons.bakery_dining_rounded,
        startColor: Color(0xFF3B2F2F),
        endColor: Color(0xFF5A443A),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // DUMMY DATA MẪU CHẤT LƯỢNG CAO (F&B / COFFEE SHOP)
  // ---------------------------------------------------------------------------
  // DUMMY DATA MẪU CHẤT LƯỢNG CAO (24 MÓN F&B CHUẨN XU HƯỚNG HIỆN ĐẠI)
  // ---------------------------------------------------------------------------

  static const List<CategoryModel> _dummyCategories = [
    CategoryModel(
      id: 1,
      name: 'Cà Phê Việt',
      description: 'Hương vị cà phê truyền thống và biến tấu hiện đại đậm đà phong cách Việt',
      imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
      productCount: 6,
    ),
    CategoryModel(
      id: 2,
      name: 'Trà Trái Cây & Trà Sữa',
      description: 'Trà trái cây tươi mát sảng khoái cùng trà sữa béo ngậy chuẩn gu giới trẻ',
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
      productCount: 6,
    ),
    CategoryModel(
      id: 3,
      name: 'Đá Xay & Matcha',
      description: 'Thức uống đá xay mát lạnh, béo ngậy và bột trà xanh Matcha Nhật Bản',
      imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80',
      productCount: 6,
    ),
    CategoryModel(
      id: 4,
      name: 'Bánh Ngọt & Ăn Vặt',
      description: 'Bánh nướng bơ thơm lừng, tiramisu mềm mịn và các món ăn vặt nhâm nhi hấp dẫn',
      imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80',
      productCount: 6,
    ),
  ];

  static const List<ProductModel> _dummyProducts = [
    // --- 1. Cà Phê Việt ---
    ProductModel(
      id: 1,
      name: 'Cà Phê Sữa Đá Sài Gòn',
      description: 'Hạt Robusta Buôn Ma Thuột rang mộc hòa quyện cùng sữa đặc béo ngậy và đá lạnh sảng khoái.',
      price: 29000,
      imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
      categoryId: 1,
      categoryName: 'Cà Phê Việt',
      rating: 4.9,
      isBestSeller: true,
    ),
    ProductModel(
      id: 2,
      name: 'Cà Phê Đen Đá Buôn Ma Thuột',
      description: 'Robusta nguyên chất 100% rang mộc truyền thống, thơm nồng đắng dịu và hậu vị ngọt sâu lắng.',
      price: 25000,
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=600&q=80',
      categoryId: 1,
      categoryName: 'Cà Phê Việt',
      rating: 4.8,
      isBestSeller: false,
    ),
    ProductModel(
      id: 3,
      name: 'Bạc Xỉu 3 Tầng Kem Sữa',
      description: 'Hòa quyện tinh tế giữa sữa đặc ngọt ngào, sữa tươi thanh mát và lớp cà phê thơm lừng bên trên.',
      price: 35000,
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=600&q=80',
      categoryId: 1,
      categoryName: 'Cà Phê Việt',
      rating: 4.9,
      isBestSeller: true,
    ),
    ProductModel(
      id: 4,
      name: 'Cà Phê Muối Cố Đô',
      description: 'Vị đắng đượm của cà phê phin hòa quyện cùng lớp kem béo mặn mà đặc trưng xứ Huế khó quên.',
      price: 39000,
      imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=600&q=80',
      categoryId: 1,
      categoryName: 'Cà Phê Việt',
      rating: 4.9,
      isBestSeller: true,
    ),
    ProductModel(
      id: 5,
      name: 'Cold Brew Cam Vàng',
      description: 'Cà phê ủ lạnh 16 tiếng chiết xuất hương vị thanh khiết kết hợp lát cam vàng mọng nước sảng khoái.',
      price: 45000,
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=600&q=80',
      categoryId: 1,
      categoryName: 'Cà Phê Việt',
      rating: 4.8,
      isBestSeller: false,
    ),
    ProductModel(
      id: 6,
      name: 'Cà Phê Trứng Hà Nội',
      description: 'Lớp kem trứng đánh bông mịn như nhung béo ngậy phủ trên nền cà phê phin nóng hổi truyền thống.',
      price: 45000,
      imageUrl: 'https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=600&q=80',
      categoryId: 1,
      categoryName: 'Cà Phê Việt',
      rating: 4.7,
      isBestSeller: false,
    ),

    // --- 2. Trà Trái Cây & Trà Sữa ---
    ProductModel(
      id: 7,
      name: 'Trà Đào Cam Sả Tươi',
      description: 'Trà đen ủ lạnh kết hợp vị chua ngọt của cam vàng, hương thơm tinh tế của sả tươi và đào giòn thơm.',
      price: 42000,
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
      categoryId: 2,
      categoryName: 'Trà Trái Cây & Trà Sữa',
      rating: 4.9,
      isBestSeller: true,
    ),
    ProductModel(
      id: 8,
      name: 'Trà Mãng Cầu Xiêm Nhiệt Đới',
      description: 'Thịt mãng cầu xiêm tươi dầm mọng nước kết hợp nền trà lài thanh tao, chua ngọt giải nhiệt cực đã.',
      price: 45000,
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      categoryId: 2,
      categoryName: 'Trà Trái Cây & Trà Sữa',
      rating: 4.8,
      isBestSeller: false,
    ),
    ProductModel(
      id: 9,
      name: 'Trà Sữa Trân Châu Đường Đen',
      description: 'Trà sữa béo thơm hòa quyện trân châu hoàng kim dẻo dai phủ mật mía đường đen đậm đà sóng sánh.',
      price: 45000,
      imageUrl: 'https://images.unsplash.com/photo-1558857563-b371033873b8?auto=format&fit=crop&w=600&q=80',
      categoryId: 2,
      categoryName: 'Trà Trái Cây & Trà Sữa',
      rating: 5.0,
      isBestSeller: true,
    ),
    ProductModel(
      id: 10,
      name: 'Ô Long Kem Phô Mai (Macchiato)',
      description: 'Nước cốt trà ô long hảo hạng thơm mùi hoa cỏ phủ lớp kem cheese mặn béo ngậy quyến rũ.',
      price: 48000,
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80',
      categoryId: 2,
      categoryName: 'Trà Trái Cây & Trà Sữa',
      rating: 4.9,
      isBestSeller: true,
    ),
    ProductModel(
      id: 11,
      name: 'Trà Vải Hoa Hồng Băng Tuyết',
      description: 'Vị ngọt thanh tao của trái vải chín mọng kết hợp siro hoa hồng tự nhiên và thạch dòn sần sật.',
      price: 45000,
      imageUrl: 'https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?auto=format&fit=crop&w=600&q=80',
      categoryId: 2,
      categoryName: 'Trà Trái Cây & Trà Sữa',
      rating: 4.7,
      isBestSeller: false,
    ),
    ProductModel(
      id: 12,
      name: 'Trà Sữa Oolong Nướng Trân Châu',
      description: 'Trà ô long sấy đậm vị khói caramel độc đáo hòa quyện cốt sữa New Zealand béo đậm đà khó cưỡng.',
      price: 49000,
      imageUrl: 'https://images.unsplash.com/photo-1558857563-b371033873b8?auto=format&fit=crop&w=600&q=80',
      categoryId: 2,
      categoryName: 'Trà Trái Cây & Trà Sữa',
      rating: 4.8,
      isBestSeller: false,
    ),

    // --- 3. Đá Xay & Matcha ---
    ProductModel(
      id: 13,
      name: 'Matcha Latte Uji Kyoto',
      description: 'Bột trà xanh Uji cao cấp từ cố đô Kyoto hòa quyện cùng sữa tươi thanh trùng ngọt dịu bổ dưỡng.',
      price: 48000,
      imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=600&q=80',
      categoryId: 3,
      categoryName: 'Đá Xay & Matcha',
      rating: 4.9,
      isBestSeller: true,
    ),
    ProductModel(
      id: 14,
      name: 'Matcha Đá Xay Kem Whipping',
      description: 'Matcha Nhật xay nhuyễn mịn cùng sữa tuyết mát lạnh, phủ ngọn kem tươi whipping cream ngọt ngào.',
      price: 55000,
      imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=600&q=80',
      categoryId: 3,
      categoryName: 'Đá Xay & Matcha',
      rating: 4.8,
      isBestSeller: false,
    ),
    ProductModel(
      id: 15,
      name: 'Cookie Đá Xay Socola',
      description: 'Bánh quy Oreo giòn rụm xay cùng sốt socola Bỉ đậm đà và bọt kem tươi hấp dẫn cuốn hút.',
      price: 52000,
      imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80',
      categoryId: 3,
      categoryName: 'Đá Xay & Matcha',
      rating: 4.8,
      isBestSeller: false,
    ),
    ProductModel(
      id: 16,
      name: 'Choco Mint Đá Xay Mát Lạnh',
      description: 'Sự kết hợp hoàn hảo giữa socola đen béo đắng và tinh chất bạc hà the mát bừng tỉnh năng lượng.',
      price: 52000,
      imageUrl: 'https://images.unsplash.com/photo-1577805947697-89e18249d767?auto=format&fit=crop&w=600&q=80',
      categoryId: 3,
      categoryName: 'Đá Xay & Matcha',
      rating: 4.7,
      isBestSeller: false,
    ),
    ProductModel(
      id: 17,
      name: 'Caramel Freeze Đá Xay Hạt Dẻ',
      description: 'Cà phê đá xay sốt caramel sánh quyện kết hợp siro hạt dẻ bùi béo và vụn kẹo giòn tan.',
      price: 55000,
      imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=600&q=80',
      categoryId: 3,
      categoryName: 'Đá Xay & Matcha',
      rating: 4.9,
      isBestSeller: true,
    ),
    ProductModel(
      id: 18,
      name: 'Sinh Tố Bơ Dừa Xay Nhuyễn',
      description: 'Bơ sáp Tây Nguyên dẻo quánh xay cùng nước cốt dừa Bến Tre và sữa đặc béo ngậy thơm ngon.',
      price: 49000,
      imageUrl: 'https://images.unsplash.com/photo-1623065422902-30a2d299bbe4?auto=format&fit=crop&w=600&q=80',
      categoryId: 3,
      categoryName: 'Đá Xay & Matcha',
      rating: 4.8,
      isBestSeller: false,
    ),

    // --- 4. Bánh Ngọt & Ăn Vặt ---
    ProductModel(
      id: 19,
      name: 'Bánh Sừng Trâu Croissant Bơ Pháp',
      description: 'Vỏ ngàn lớp vàng óng giòn rụm, ruột xốp mềm thơm nức bơ tươi New Zealand thượng hạng.',
      price: 35000,
      imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80',
      categoryId: 4,
      categoryName: 'Bánh Ngọt & Ăn Vặt',
      rating: 4.9,
      isBestSeller: true,
    ),
    ProductModel(
      id: 20,
      name: 'Bánh Tiramisu Cacao Ý',
      description: 'Lớp kem Mascarpone mềm mượt quyện đượm cùng cà phê Espresso và bột cacao nguyên chất phủ đều.',
      price: 45000,
      imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=600&q=80',
      categoryId: 4,
      categoryName: 'Bánh Ngọt & Ăn Vặt',
      rating: 5.0,
      isBestSeller: true,
    ),
    ProductModel(
      id: 21,
      name: 'Bánh Mì Que Hải Phòng Pate Cay',
      description: 'Bánh mì que nướng giòn rụm kẹp pate gan thơm béo cùng tương ớt cay nồng đậm vị đất Cảng.',
      price: 18000,
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80',
      categoryId: 4,
      categoryName: 'Bánh Ngọt & Ăn Vặt',
      rating: 4.7,
      isBestSeller: false,
    ),
    ProductModel(
      id: 22,
      name: 'Bánh Waffle Bỉ Sốt Mật Ong',
      description: 'Bánh waffle nướng nóng hổi giòn rụm thơm nức bơ tươi, rưới mật ong nguyên chất ngọt ngào mê đắm.',
      price: 38000,
      imageUrl: 'https://images.unsplash.com/photo-1562376552-0d160a2f238d?auto=format&fit=crop&w=600&q=80',
      categoryId: 4,
      categoryName: 'Bánh Ngọt & Ăn Vặt',
      rating: 4.8,
      isBestSeller: false,
    ),
    ProductModel(
      id: 23,
      name: 'Khoai Tây Chiên Lắc Phô Mai',
      description: 'Khoai tây cọng giòn tan bên ngoài, bùi béo bên trong lắc đều bột phô mai Cheddar béo thơm.',
      price: 35000,
      imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=600&q=80',
      categoryId: 4,
      categoryName: 'Bánh Ngọt & Ăn Vặt',
      rating: 4.7,
      isBestSeller: false,
    ),
    ProductModel(
      id: 24,
      name: 'Bánh Mousse Chanh Leo Nhiệt Đới',
      description: 'Cốt bánh mềm mịn chua ngọt dịu dàng mát lạnh, cân bằng hoàn hảo cho buổi chiều thư giãn.',
      price: 42000,
      imageUrl: 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=600&q=80',
      categoryId: 4,
      categoryName: 'Bánh Ngọt & Ăn Vặt',
      rating: 4.8,
      isBestSeller: false,
    ),
  ];
}
