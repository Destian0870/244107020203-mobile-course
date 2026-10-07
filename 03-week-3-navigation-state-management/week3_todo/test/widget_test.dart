import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/main.dart';

void main() {
  testWidgets('TodoApp render test', (WidgetTester tester) async {
    // Build apps di dalam ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verifikasi bahwa aplikasi berhasil dirender tanpa error
    expect(find.byType(MyApp), findsOneWidget);
  });
}
