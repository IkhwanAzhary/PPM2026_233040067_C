// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:pertemuan_3/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Karena aplikasi sudah berubah menjadi Catatan Mahasiswa, 
    // test default counter ini kemungkinan akan gagal saat dijalankan.
    // Namun, baris di bawah diperbaiki agar tidak error secara sintaks.
    
    // Contoh verifikasi sederhana untuk aplikasi Catatan:
    expect(find.text('Catatan Mahasiswa'), findsOneWidget);
  });
}
