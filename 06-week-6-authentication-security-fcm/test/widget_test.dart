import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Aplikasi berjalan dengan dasar MaterialApp', (WidgetTester tester) async {
    // Tes sederhana untuk memastikan environment test widget berjalan normal
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Campus Notify'),
          ),
        ),
      ),
    );

    expect(find.text('Campus Notify'), findsOneWidget);
  });
}