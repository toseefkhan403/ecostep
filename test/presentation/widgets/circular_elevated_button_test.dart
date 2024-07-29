import 'package:ecostep/presentation/widgets/circular_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CircularElevatedButton is created successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CircularElevatedButton(
            onPressed: () {},
            child: const Text('Button'),
          ),
        ),
      ),
    );

    expect(find.byType(CircularElevatedButton), findsOneWidget);
    expect(find.text('Button'), findsOneWidget);
  });
}
