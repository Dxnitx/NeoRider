import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neorider_app/screens/profile_screen.dart';
import 'package:neorider_app/screens/device/device_screen.dart';

void main() {
  testWidgets('profile screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Rider'), findsOneWidget);
  });

  testWidgets('Helmet & Device opens Device screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ProfileScreen(),
        routes: {'/device': (_) => const DeviceScreen()},
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Helmet & Device'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Helmet & Device'));
    await tester.pumpAndSettle();

    expect(find.byType(DeviceScreen), findsOneWidget);
    expect(find.text('NeoRider Device'), findsOneWidget);
    expect(find.text('Disconnected'), findsOneWidget);
  });
}
