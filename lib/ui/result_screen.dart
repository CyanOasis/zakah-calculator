import 'package:flutter/material.dart';
import 'package:zakat/l10n/app_localizations.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/zakat_provider.dart';
import '../services/local_history_service.dart';
import 'widgets/custom_widgets.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZakatProvider>();
    final currencyFormat = NumberFormat.currency(
      symbol: '${provider.selectedCountry.currency} ',
      decimalDigits: 2,
    );

    final bool isEligible = provider.isZakatDue;
    final Color mainColor = isEligible ? Theme.of(context).colorScheme.primary : const Color(0xFFE57373);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.result_title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A462C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildResultHeader(context, provider, currencyFormat, mainColor),
            const SizedBox(height: 32),
            _buildDetailedBreakdown(context, provider, currencyFormat),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await LocalHistoryService().saveCalculation(
                    category: 'wealth',
                    totalAssets: provider.totalAssets,
                    totalLiabilities: provider.debts,
                    netWealth: provider.netWealth,
                    zakatDue: provider.zakatDue,
                    currency: provider.selectedCountry.currency,
                    details: {
                      'cash': provider.cash,
                      'bank': provider.bank,
                      'gold_weight': provider.goldWeight,
                      'gold_carat': provider.goldCarat,
                      'silver_weight': provider.silverWeight,
                      'investments': provider.investments,
                      'business_assets': provider.businessAssets,
                      'receivables': provider.receivables,
                      'other_assets': provider.otherAssets,
                      'debts': provider.debts,
                      'nisab_method': provider.nisabMethod,
                      'hawl_completed': provider.hawlCompleted,
                    },
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calculation saved to history.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save to History'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 30),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.tazkiyah_note,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.amber.shade900, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(AppLocalizations.of(context)!.finish_save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.edit_inputs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context, ZakatProvider provider, NumberFormat format, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            provider.isZakatDue ? Icons.check_circle_outline : Icons.info_outline,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            provider.isZakatDue ? AppLocalizations.of(context)!.zakat_due : AppLocalizations.of(context)!.no_zakat,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              format.format(provider.zakatDue),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            provider.isZakatDue
                ? AppLocalizations.of(context)!.eligible_desc
                : (provider.isZakatEligible ? AppLocalizations.of(context)!.hawl_pending_desc : AppLocalizations.of(context)!.not_eligible_desc),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown(BuildContext context, ZakatProvider provider, NumberFormat format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.wealth_summary, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ProfessionalCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildReportRow(AppLocalizations.of(context)!.total_assets, format.format(provider.totalAssets)),
              const SizedBox(height: 12),
              _buildReportRow(AppLocalizations.of(context)!.total_liabilities, '- ${format.format(provider.debts)}', color: Colors.red),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(),
              ),
              _buildReportRow(AppLocalizations.of(context)!.net_wealth, format.format(provider.netWealth), isBold: true),
              const SizedBox(height: 12),
              _buildReportRow(provider.nisabMethod == 'gold' ? AppLocalizations.of(context)!.gold_nisab : AppLocalizations.of(context)!.silver_nisab, format.format(provider.selectedNisabThreshold), isGrey: true),
              const SizedBox(height: 12),
              _buildReportRow(
                AppLocalizations.of(context)!.nisab_method,
                provider.nisabMethod == 'gold' ? AppLocalizations.of(context)!.gold_nisab_option : AppLocalizations.of(context)!.silver_nisab_option,
                isGrey: true,
              ),
              const SizedBox(height: 12),
              _buildReportRow(
                AppLocalizations.of(context)!.hawl_completed,
                provider.hawlCompleted
                    ? AppLocalizations.of(context)!.yes_text
                    : AppLocalizations.of(context)!.no_text,
                isGrey: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportRow(String label, String value, {bool isBold = false, bool isGrey = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isGrey ? Colors.grey : (isBold ? Colors.black87 : Colors.grey[700]),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? (isBold ? Colors.black87 : Colors.black54),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
