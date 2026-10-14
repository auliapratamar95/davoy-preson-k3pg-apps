import 'package:flutter_test/flutter_test.dart';
import 'package:preson_apps/main.dart';

void main() {
  testWidgets('DAVOY app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DavoyApp());
    expect(find.byType(DavoyApp), findsOneWidget);
  });
}
