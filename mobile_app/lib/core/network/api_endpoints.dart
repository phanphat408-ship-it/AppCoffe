import 'package:flutter/foundation.dart';

/// Danh sách đường dẫn API Backend khớp với ASP.NET Core API
class ApiEndpoints {
  ApiEndpoints._();

  /// Địa chỉ Base URL máy chủ:
  /// - Khi chạy trên Android Emulator: 10.0.2.2:5108
  /// - Khi chạy Web / Desktop / iOS Simulator: localhost:5108
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5108';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5108';
    }
    return 'http://localhost:5108';
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
