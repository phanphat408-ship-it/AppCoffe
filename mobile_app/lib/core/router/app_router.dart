import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_notifier.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/branches/presentation/screens/branch_map_screen.dart';
import '../../features/cart/data/models/order_models.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/cart/presentation/order_success_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Class lắng nghe AuthNotifier và thông báo cho GoRouter kích hoạt redirect
class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous?.status != next.status) {
        notifyListeners();
      }
    });
  }
}

final authRefreshListenableProvider = Provider<AuthRefreshListenable>((ref) {
  return AuthRefreshListenable(ref);
});

/// Provider cấu hình GoRouter cho toàn ứng dụng
final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(authRefreshListenableProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    refreshListenable: refreshListenable,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      // Khi đang kiểm tra Token ban đầu, giữ nguyên luồng
      if (authState.isInitial) {
        return null;
      }

      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isRegistering = state.matchedLocation == AppRoutes.register;
      final isAuthRoute = isLoggingIn || isRegistering;

      // 1. Nếu ĐÃ có Token hợp lệ -> chuyển thẳng vào Home Screen khi đang ở Login/Register
      if (authState.isAuthenticated) {
        if (isAuthRoute) {
          return AppRoutes.home;
        }
      } else {
        // 2. Nếu CHƯA có Token -> chỉ cho phép ở Login/Register hoặc xem Home vãng lai
        // Khi truy cập giỏ hàng hoặc hồ sơ cá nhân -> đưa về Login
        if (state.matchedLocation == AppRoutes.cart ||
            state.matchedLocation == AppRoutes.homeCart ||
            state.matchedLocation == AppRoutes.checkout ||
            state.matchedLocation == AppRoutes.orderSuccess ||
            state.matchedLocation == AppRoutes.profile) {
          return AppRoutes.login;
        }
      }

      return null;
    },
    routes: [
      // 1. Màn hình Đăng nhập (Login)
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),

      // 2. Màn hình Đăng ký (Register)
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),

      // 3. Màn hình Chính (Main Scaffold gồm 3 tab: Home, Orders, Profile)
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const MainScreen(),
        routes: [
          // Sub-route: Giỏ hàng mở từ Trang chủ
          GoRoute(
            path: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
        ],
      ),

      // Tab Đơn hàng
      GoRoute(
        path: AppRoutes.orders,
        name: AppRoutes.ordersName,
        builder: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(mainTabIndexProvider.notifier).setTab(1);
          });
          return const MainScreen();
        },
      ),

      // Tab Hồ sơ cá nhân
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profileName,
        builder: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(mainTabIndexProvider.notifier).setTab(2);
          });
          return const MainScreen();
        },
      ),

      // 4. Màn hình Giỏ hàng độc lập (Cart)
      GoRoute(
        path: AppRoutes.cart,
        name: AppRoutes.cartName,
        builder: (context, state) => const CartScreen(),
      ),

      // 4.1 Màn hình Xác nhận Đơn hàng & Thanh toán (Checkout)
      GoRoute(
        path: AppRoutes.checkout,
        name: AppRoutes.checkoutName,
        builder: (context, state) => const CheckoutScreen(),
      ),

      // 5. Màn hình Đặt hàng thành công (nhận OrderResult qua `extra`)
      GoRoute(
        path: AppRoutes.orderSuccess,
        name: AppRoutes.orderSuccessName,
        builder: (context, state) {
          final extra = state.extra;
          return OrderSuccessScreen(
            result: extra is OrderResult ? extra : null,
          );
        },
      ),

      // 6. Màn hình Bản đồ & Tìm chi nhánh gần nhất (Google Maps)
      GoRoute(
        path: AppRoutes.map,
        name: AppRoutes.mapName,
        builder: (context, state) => const BranchMapScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Trang không tồn tại: ${state.uri}'),
      ),
    ),
  );
});
