/// Danh sách đường dẫn API Backend khớp với ASP.NET Core API
class ApiEndpoints {
  ApiEndpoints._();

  /// Địa chỉ Base URL máy chủ kết nối với ASP.NET Core:
  /// Chuẩn kết nối máy ảo Android (Android Emulator): 10.0.2.2:5108
  static String get baseUrl {
    return 'http://10.0.2.2:5108';
  }

  // Auth endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';

  // Products & Categories
  static const String products = '/api/products';
  static const String categories = '/api/categories';

  // Cart
  static const String cart = '/api/cart';

  // Orders
  static const String orders = '/api/orders';

  // Branches
  static const String branches = '/api/branches';
}
