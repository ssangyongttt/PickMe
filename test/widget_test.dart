import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pickme/main.dart';

void main() {
  testWidgets('loads examples and picks a result', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const PickMeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('치킨 / 피자'));
    await tester.pump();

    await tester.tap(find.text('Pick Me'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.textContaining('선택됨'), findsWidgets);
  });
}
