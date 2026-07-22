import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neorider_app/screens/profile_screen.dart';

void main() {
  testWidgets('profile screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Rider'), findsOneWidget);
  });
}
