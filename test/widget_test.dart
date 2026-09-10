import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shot_oyunu/main.dart';

void main() {
  // Varsayılan test yüzeyi GridView'in tüm 2x2 kartını sığdırmayacak kadar
  // kısa olabiliyor; gerçekçi bir telefon ekranı boyutu veriyoruz.
  Future<void> setPhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Ana ekran 4 oyun modunu gösterir', (WidgetTester tester) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(const ShotOyunuApp());

    expect(find.text('Shot Oyunu'), findsOneWidget);
    expect(find.text('Kral Bardağı'), findsOneWidget);
    expect(find.text('Hiç Yapmadım'), findsOneWidget);
    expect(find.text('Kim Daha Çok'), findsOneWidget);
    expect(find.text('Çark Çevir'), findsOneWidget);
  });

  testWidgets('Kral Bardağı moduna girip kart çekilebiliyor', (WidgetTester tester) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(const ShotOyunuApp());
    await tester.tap(find.text('Kral Bardağı'));
    await tester.pumpAndSettle();

    expect(find.text('KARTI ÇEK'), findsOneWidget);
    await tester.tap(find.text('KARTI ÇEK'));
    await tester.pumpAndSettle();

    expect(find.text('SIRADAKİ KART'), findsOneWidget);
  });
}
