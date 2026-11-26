// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:jalanyuk/main.dart';

void main() {
  testWidgets('JalanYuk shows the booking screen', (WidgetTester tester) async {
    await tester.pumpWidget(const JalanYukApp());

    expect(find.text('JalanYuk • Pesan Travel'), findsOneWidget);
    expect(find.text('Pilih Kursi (Rp75.000 / kursi)'), findsOneWidget);
    expect(find.text('Total: Rp75.000'), findsOneWidget);
    expect(find.text('Lanjut ke Pembayaran'), findsOneWidget);
    expect(find.text('Pesan'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Promo'), findsOneWidget);
  });
}
