import 'package:flutter_test/flutter_test.dart';
import 'package:sheild_app/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SHEildApp());
    expect(find.text('SHEild'), findsOneWidget);
  });
}
