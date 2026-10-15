import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/home_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

/// Provider quản lý Tab hiện tại trên thanh BottomNavigationBar (0: Home, 1: Orders, 2: Profile)
final mainTabIndexProvider =
    NotifierProvider<MainTabNotifier, int>(MainTabNotifier.new);

class MainTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

/// Màn hình Scaffold chính (Main Scaffold) chứa BottomNavigationBar 3 tab
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainTabIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomeScreen(),
          OrdersScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            height: 64,
            elevation: 0,
            backgroundColor: Colors.white,
            indicatorColor: AppColors.secondary.withValues(alpha: 0.5),
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              ref.read(mainTabIndexProvider.notifier).setTab(index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Trang chủ',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                label: 'Đơn hàng',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                label: 'Hồ sơ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
