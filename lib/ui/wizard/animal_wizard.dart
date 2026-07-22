import 'package:flutter/material.dart';
import 'package:zakat/l10n/app_localizations.dart';

import 'package:provider/provider.dart';
import '../../providers/zakat_provider.dart';
import '../../services/local_history_service.dart';
import '../widgets/custom_widgets.dart';

class AnimalWizard extends StatefulWidget {
  const AnimalWizard({super.key});

  @override
  State<AnimalWizard> createState() => _AnimalWizardState();
}

class _AnimalWizardState extends State<AnimalWizard> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZakatProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.animal_title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A462C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.animal_desc, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            CustomInputField(
              label: AppLocalizations.of(context)!.sheep_count,
              hint: '0',
              icon: Icons.pets,
              onChanged: (v) => provider.updateAnimalCounts(sheep: ZakatProvider.parseLocalizedDouble(v).toInt()),
            ),
            CustomInputField(
              label: AppLocalizations.of(context)!.cow_count,
              hint: '0',
              icon: Icons.agriculture,
              onChanged: (v) => provider.updateAnimalCounts(cow: ZakatProvider.parseLocalizedDouble(v).toInt()),
            ),
            CustomInputField(
              label: AppLocalizations.of(context)!.camel_count,
              hint: '0',
              icon: Icons.terrain,
              onChanged: (v) => provider.updateAnimalCounts(camel: ZakatProvider.parseLocalizedDouble(v).toInt()),
            ),
            const SizedBox(height: 40),
            ProfessionalCard(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.zakat_due, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    provider.animalZakatResult,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await LocalHistoryService().saveCalculation(
                  category: 'animal',
                  totalAssets: 0,
                  totalLiabilities: 0,
                  netWealth: 0,
                  zakatDue: 0,
                  currency: provider.selectedCountry.currency,
                  details: {
                    'sheep_count': provider.sheepCount,
                    'cow_count': provider.cowCount,
                    'camel_count': provider.camelCount,
                    'animal_zakat_due': provider.animalZakatResult,
                  },
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Animal calculation saved to history.')),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.finish_save),
            ),
          ],
        ),
      ),
    );
  }
}
