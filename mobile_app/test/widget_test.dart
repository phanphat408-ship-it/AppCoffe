import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/presentation/login_screen.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('CoffeeShopApp boots up successfully with theme and login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CoffeeShopApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that Login Screen is rendered
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Chào Mừng Trở Lại! ☕'), findsOneWidget);
  });
}
