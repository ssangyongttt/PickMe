import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pickme/main.dart';

void main() {
  testWidgets('adds options and picks a result', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const PickMeApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '치킨');
    await tester.tap(find.text('추가'));
    await tester.pump();

    await tester.enterText(find.byType(EditableText), '피자');
    await tester.tap(find.text('추가'));
    await tester.pump();

    expect(find.text('치킨'), findsOneWidget);
    expect(find.text('피자'), findsOneWidget);

    await tester.tap(find.text('Pick Me'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.textContaining('선택됨'), findsWidgets);
  });
}
