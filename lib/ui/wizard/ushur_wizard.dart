import 'package:flutter/material.dart';
import 'package:zakat/l10n/app_localizations.dart';

import 'package:provider/provider.dart';
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
            const SizedBox(height: 20),
            const Text(
              'Irrigation Method (সেচ পদ্ধতি)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF263238)),
            ),
            const SizedBox(height: 10),
            _buildIrrigationOption(
              title: 'Natural Irrigation (প্রাকৃতিক সেচ)',
              subtitle: 'Rain, river, or spring water — 10% Zakat (উশর)',
              selected: provider.irrigationMethod == IrrigationMethod.natural,
              onTap: () => provider.updateUshur(method: IrrigationMethod.natural),
            ),
            const SizedBox(height: 10),
            _buildIrrigationOption(
              title: 'Artificial / Purchased (কৃত্রিম সেচ)',
              subtitle: 'Tube-well, electric pump, or purchased water — 5% Zakat (অর্ধ-উশর)',
              selected: provider.irrigationMethod == IrrigationMethod.artificial,
              onTap: () => provider.updateUshur(method: IrrigationMethod.artificial),
            ),
            const SizedBox(height: 10),
            _buildIrrigationOption(
              title: 'Mixed Irrigation (যৌথ / মিশ্র সেচ)',
              subtitle: 'Both rain & artificial pump irrigation — 7.5% Zakat (তিন-চতুর্থাংশ উশর)',
              selected: provider.irrigationMethod == IrrigationMethod.mixed,
              onTap: () => provider.updateUshur(method: IrrigationMethod.mixed),
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                    'irrigation_method': provider.irrigationMethod.name,
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

  Widget _buildIrrigationOption({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0A462C).withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF0A462C) : const Color(0xFFE0E0E0),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFF0A462C) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      color: const Color(0xFF263238),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
