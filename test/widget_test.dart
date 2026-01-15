import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_slipgaji/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MySalaryApp());

    expect(find.text('My Salary'), findsWidgets);
    expect(find.text('Masuk'), findsOneWidget);
  });
}