import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zakat/l10n/app_localizations.dart';

class HistoryDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final NumberFormat format;

  const HistoryDetailsScreen({
    super.key,
    required this.item,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final details = Map<String, dynamic>.from(item['details'] as Map);
    final date = DateTime.parse(item['calculation_date'] as String);
    final currency = item['currency'];
    final bool isDraft = item['zakat_due'] == 0.0;
    
    // Fallbacks for details if missing
    final double totalAssets = (item['total_assets'] as num?)?.toDouble() ?? 0.0;
    final double liabilities = (item['total_liabilities'] as num?)?.toDouble() ?? 0.0;
    final double zakatDue = (item['zakat_due'] as num?)?.toDouble() ?? 0.0;
    final String nisabThreshold = details['নিছাব সীমা']?.toString() ?? '87,840.00';

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: Text(loc.history_details, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF0A462C),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              // Delete action would go here
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header Card
                    _buildTopCard(currency, zakatDue, date, isDraft, loc),
                    const SizedBox(height: 24),
                    
                    // Summary Section
                    Text(loc.history_details_summary, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2923))),
                    const SizedBox(height: 12),
                    _buildSummaryGrid(currency, nisabThreshold, totalAssets, zakatDue, loc),
                    const SizedBox(height: 24),
                    
                    // Asset Breakdown
                    Text(loc.history_details_asset_breakdown, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2923))),
                    const SizedBox(height: 12),
                    _buildAssetBreakdown(details, currency, loc),
                    const SizedBox(height: 24),
                    
                    // Zakat Breakdown
                    Text(loc.history_details_zakat_breakdown, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2923))),
                    const SizedBox(height: 12),
                    _buildZakatBreakdown(totalAssets, liabilities, zakatDue, currency, loc),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Share Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Share action
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text(loc.history_details_share, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A462C),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(String currency, double zakatDue, DateTime date, bool isDraft, AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0A462C).withOpacity(0.1)),
            ),
            child: const Icon(Icons.calculate_outlined, color: Color(0xFF0A462C), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Zakah Calculation', style: TextStyle(fontSize: 14, color: Color(0xFF5F6763))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDraft ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDraft ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        isDraft ? loc.history_filter_draft : loc.history_filter_completed,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDraft ? Colors.orange[800] : const Color(0xFF0A462C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$currency ${format.format(zakatDue)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E2923)),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat("dd MMM yyyy, hh:mm a").format(date),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(String currency, String nisabThreshold, double totalAssets, double zakatDue, AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryItem(Icons.adjust, const Color(0xFF10B981), loc.nisab_threshold.split(' (').first + '\n(${loc.nisab_threshold.split(' (').last}', '$currency $nisabThreshold'),
          _buildSummaryItem(Icons.inventory_2_outlined, const Color(0xFFF59E0B), loc.total_assets, '$currency ${format.format(totalAssets)}'),
          _buildSummaryItem(Icons.percent, const Color(0xFF10B981), loc.history_details_zakat_rate, '2.5%'),
          _buildSummaryItem(Icons.calculate_outlined, const Color(0xFF6B7280), loc.history_details_total_zakat, '$currency ${format.format(zakatDue)}', valueColor: const Color(0xFF0A462C)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, Color iconColor, String title, String value, {Color? valueColor}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFF4B5563), height: 1.3)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: valueColor ?? const Color(0xFF1F2937))),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetBreakdown(Map<String, dynamic> details, String currency, AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAssetRow(Icons.money, const Color(0xFF10B981), loc.history_details_cash_assets, loc.history_details_cash_home, _getDetailValue(details, 'নগদ_টাকা', 'নগদ টাকা (বাসায়)'), currency),
          _buildDivider(),
          _buildAssetRow(Icons.account_balance, const Color(0xFF3B82F6), loc.history_details_bank_deposits, loc.history_details_bank_accounts, _getDetailValue(details, 'ব্যাংক_জমা', 'ব্যাংক একাউন্ট'), currency),
          _buildDivider(),
          _buildAssetRow(Icons.diamond, const Color(0xFFF59E0B), loc.history_details_gold, '22 Carat, 25.00g', _getDetailValue(details, 'স্বর্ণ'), currency),
          _buildDivider(),
          _buildAssetRow(Icons.circle_outlined, const Color(0xFF9CA3AF), loc.history_details_silver, 'Pure Silver, 100.00g', _getDetailValue(details, 'রূপা'), currency),
          _buildDivider(),
          _buildAssetRow(Icons.shopping_bag_outlined, const Color(0xFFEC4899), loc.history_details_business_goods, loc.history_details_stock_items, _getDetailValue(details, 'ব্যবসার_পণ্য'), currency),
          _buildDivider(),
          _buildAssetRow(Icons.card_giftcard, const Color(0xFFF97316), loc.history_details_other_assets, loc.history_details_furniture_etc, _getDetailValue(details, 'অন্যান্য', 'বিনিয়োগ'), currency),
        ],
      ),
    );
  }
  
  double _getDetailValue(Map<String, dynamic> details, String key1, [String? key2]) {
    if (details.containsKey(key1)) return (details[key1] as num).toDouble();
    if (key2 != null && details.containsKey(key2)) return (details[key2] as num).toDouble();
    
    // Look for partial matches
    for (var k in details.keys) {
      if (k.contains(key1) || (key2 != null && k.contains(key2))) {
        if (details[k] is num) return (details[k] as num).toDouble();
      }
    }
    return 0.0;
  }

  Widget _buildAssetRow(IconData icon, Color iconColor, String title, String subtitle, double amount, String currency) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Text('$currency ${format.format(amount)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.withOpacity(0.1), height: 24, thickness: 1);
  }

  Widget _buildZakatBreakdown(double totalAssets, double liabilities, double zakatDue, String currency, AppLocalizations loc) {
    final double zakatOnAssets = totalAssets * 0.025; // Approximate
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.history_details_zakat_on_assets, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
              Text('$currency ${format.format(zakatOnAssets)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.history_details_liabilities_expenses, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
              Text('- $currency ${format.format(liabilities)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Color(0xFFF3F4F6), thickness: 2, height: 1),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.history_details_payable_zakat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A462C))),
                Text('$currency ${format.format(zakatDue)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A462C))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
