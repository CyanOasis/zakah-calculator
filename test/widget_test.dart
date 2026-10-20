import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zakat/main.dart';
import 'package:zakat/providers/zakat_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ZakatProvider Logic & Fiqh Tests', () {
    late ZakatProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = ZakatProvider();
    });

    test('Bengali and English numeral parsing converts correctly to double', () {
      expect(ZakatProvider.parseLocalizedDouble('1234.50'), 1234.50);
      expect(ZakatProvider.parseLocalizedDouble('১২৩৪.৫০'), 1234.50);
      expect(ZakatProvider.parseLocalizedDouble('১,০০,০০০'), 100000.0);
      expect(ZakatProvider.parseLocalizedDouble(''), 0.0);
      expect(ZakatProvider.parseLocalizedDouble(null), 0.0);
    });

    test('Ushur 5 Wasaq Nisab threshold (653 kg) is strictly enforced', () {
      // Below Nisab: 500 kg
      provider.updateUshur(yieldAmount: 500.0, isNatural: true);
      expect(provider.isUshurEligible, isFalse);
      expect(provider.ushurDue, 0.0);

      // At or above Nisab (Natural irrigation = 10%)
      provider.updateUshur(yieldAmount: 1000.0, isNatural: true);
      expect(provider.isUshurEligible, isTrue);
      expect(provider.ushurDue, 100.0);

      // At or above Nisab (Artificial irrigation = 5%)
      provider.updateUshur(yieldAmount: 1000.0, isNatural: false);
      expect(provider.isUshurEligible, isTrue);
      expect(provider.ushurDue, 50.0);
    });

    test('Livestock Zakat applies accurate Fiqh brackets', () {
      // Sheep (Nisab = 40)
      provider.updateAnimalCounts(sheep: 39, cow: 0, camel: 0);
      expect(provider.animalZakatResult, 'No Zakat currently due');

      provider.updateAnimalCounts(sheep: 40, cow: 0, camel: 0);
      expect(provider.animalZakatResult, '1 sheep');

      // Cows (Nisab = 30)
      provider.updateAnimalCounts(sheep: 0, cow: 30, camel: 0);
      expect(provider.animalZakatResult, contains("Tabi'"));

      // Camels (Nisab = 5)
      provider.updateAnimalCounts(sheep: 0, cow: 0, camel: 5);
      expect(provider.animalZakatResult, '1 sheep');
    });

    test('Hawl completed vs pending estimated Zakat calculation', () {
      provider.cash = 1000000.0; // Well above Nisab
      provider.hawlCompleted = false;

      expect(provider.isZakatEligible, isTrue);
      expect(provider.isHawlPending, isTrue);
      expect(provider.estimatedZakat, 25000.0);
      expect(provider.zakatDue, 25000.0);
      expect(provider.isZakatDue, isFalse);

      provider.hawlCompleted = true;
      expect(provider.isHawlPending, isFalse);
      expect(provider.isZakatDue, isTrue);
      expect(provider.zakatDue, 25000.0);
    });
  });

  group('App Smoke Test', () {
    testWidgets('App loads initial widget tree with Provider', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ZakatProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Advance through splash delay
      await tester.pump(const Duration(seconds: 3));

      // Verify MaterialApp renders without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
