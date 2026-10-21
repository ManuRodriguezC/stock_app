import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_app/core/theme/app_theme.dart';
import 'package:stock_app/screens/main_shell_screen.dart';

void main() {
  testWidgets('App smoke test renders navigation and screens',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MainShellScreen(),
      ),
    );

    expect(find.text('StockApp'), findsWidgets);
    expect(find.text('Panel Principal'), findsOneWidget);
  });
}
