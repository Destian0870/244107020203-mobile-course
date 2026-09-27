import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart';

void main() {
  testWidgets('Dashboard renders academic overview page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DashboardApp());

    // Verify that title is displayed
    expect(find.text('Academic Overview'), findsOneWidget);
    expect(find.text('Destian Dwi H'), findsOneWidget);
  });
}
