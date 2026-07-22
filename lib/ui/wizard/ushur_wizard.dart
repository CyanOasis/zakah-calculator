import 'package:flutter/material.dart';
import 'package:zakat/l10n/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/zakat_provider.dart';
import '../../services/local_history_service.dart';
import '../widgets/custom_widgets.dart';

class UshurWizard extends StatefulWidget {
  const UshurWizard({super.key});

  @override
  State<UshurWizard> createState() => _UshurWizardState();
}

class _UshurWizardState extends State<UshurWizard> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZakatProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.ushur_title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
            Text(AppLocalizations.of(context)!.ushur_desc, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            CustomInputField(
              label: AppLocalizations.of(context)!.yield_amount,
              hint: '0',
              icon: Icons.grass,
              suffixText: 'kg',
              onChanged: (v) => provider.updateUshur(yieldAmount: ZakatProvider.parseLocalizedDouble(v)),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.irrigation_natural, style: const TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: Text(provider.isNaturallyIrrigated ? AppLocalizations.of(context)!.irrigation_natural : AppLocalizations.of(context)!.irrigation_artificial),
              subtitle: Text(provider.isNaturallyIrrigated ? '10% Zakat' : '5% Zakat'),
              value: provider.isNaturallyIrrigated,
              onChanged: (v) => provider.updateUshur(isNatural: v),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            if (provider.cropYield > 0 && !provider.isUshurEligible)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFECB3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Yield is below the 5 Wasaq Nisab threshold (653 kg). No Ushur is due.',
                        style: TextStyle(fontSize: 12, color: Color(0xFFF57F17), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ProfessionalCard(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.ushur_due, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.ushurDue.toStringAsFixed(2)} kg',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await LocalHistoryService().saveCalculation(
                  category: 'ushur',
                  totalAssets: provider.cropYield,
                  totalLiabilities: 0,
                  netWealth: provider.cropYield,
                  zakatDue: provider.ushurDue,
                  currency: provider.selectedCountry.currency,
                  details: {
                    'yield_amount': provider.cropYield,
                    'is_naturally_irrigated': provider.isNaturallyIrrigated,
                    'ushur_due': provider.ushurDue,
                  },
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ushur calculation saved to history.')),
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
