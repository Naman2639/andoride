import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EduGovernance ERP basic widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('EduGovernance ERP'),
          ),
        ),
      ),
    );

    expect(find.text('EduGovernance ERP'), findsOneWidget);
  });
}
