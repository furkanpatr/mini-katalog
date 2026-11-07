import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_katalog/main.dart';

void main() {
  testWidgets('Mini Katalog ana sayfa testi', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.pumpAndSettle();

    expect(find.text('Mini Katalog'), findsOneWidget);
    expect(find.text('Hoş Geldiniz!'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Kablosuz Kulaklık'), findsOneWidget);
  });
}
