import '../../../../core/utils/currency_formatter.dart';

/// Model món ăn & thức uống (Product)
class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String imageUrl;
  final int categoryId;
  final String? categoryName;
  final bool isAvailable;
  final double rating;
  final bool isBestSeller;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    this.categoryName,
    this.isAvailable = true,
    this.rating = 4.8,
    this.isBestSeller = false,
  });

  /// Tính điểm đánh giá sao đa dạng một cách tự nhiên (4.7 - 5.0)
  static double calculateRating(int id, String name) {
    final hash = (id * 19 + name.codeUnits.fold<int>(0, (a, b) => a + b)).abs();
    const variations = [4.9, 4.8, 4.7, 5.0, 4.8, 4.9, 4.7, 5.0, 4.8, 4.9];
    return variations[hash % variations.length];
  }

  /// Tự động xác định 8-10 món đặc trưng bán chạy nhất
  static bool computeBestSeller(int id, String name) {
    const bestSellerKeywords = [
      'sữa đá',
      'bạc xỉu',
      'cà phê muối',
      'đào cam sả',
      'đường đen',
      'ô long kem phô mai',
      'matcha latte',
      'caramel freeze',
      'croissant',
      'tiramisu',
    ];
    final lower = name.toLowerCase();
    return bestSellerKeywords.any((k) => lower.contains(k));
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final name = json['name'] as String? ?? '';
    return ProductModel(
      id: id,
      name: name,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      categoryId: json['categoryId'] as int? ?? 0,
      categoryName: json['categoryName'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? calculateRating(id, name),
      isBestSeller: json['isBestSeller'] as bool? ?? computeBestSeller(id, name),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'isAvailable': isAvailable,
      'rating': rating,
      'isBestSeller': isBestSeller,
    };
  }

  /// Format giá tiền theo định dạng Việt Nam Đồng (vd: 29.000 đ)
  String get formattedPrice => CurrencyFormatter.vnd(price);
}
