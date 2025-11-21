// Smart Home Energy App widget tests

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_home_energy/main.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartHomeApp());
    await tester.pumpAndSettle();

    // Verify that login screen elements are present
    expect(find.text('Hoş Geldiniz'), findsOneWidget);
    expect(find.text('Akıllı evinize giriş yapın'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}
