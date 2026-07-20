import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zakat_provider.dart';
import 'result_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZakatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculate Zakat', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Liquid Assets'),
              _buildInputField(
                label: 'Cash & Savings',
                hint: '0.00',
                onChanged: (val) => provider.cash = double.tryParse(val) ?? 0,
                prefixIcon: Icons.money,
                currency: provider.selectedCountry.currency,
              ),
              _buildInputField(
                label: 'Investments',
                hint: 'Stocks, Bonds, Mutual Funds',
                onChanged: (val) => provider.investments = double.tryParse(val) ?? 0,
                prefixIcon: Icons.trending_up,
                currency: provider.selectedCountry.currency,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Precious Metals'),
              _buildInputField(
                label: 'Gold Weight (grams)',
                hint: '0.00',
                onChanged: (val) => provider.goldWeight = double.tryParse(val) ?? 0,
                prefixIconAsset: 'assets/icons/gold.png',
                suffix: 'g',
              ),
              _buildInputField(
                label: 'Silver Weight (grams)',
                hint: '0.00',
                onChanged: (val) => provider.silverWeight = double.tryParse(val) ?? 0,
                prefixIconAsset: 'assets/icons/silver.png',
                suffix: 'g',
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Other Assets & Liabilities'),
              _buildInputField(
                label: 'Other Zakatable Assets',
                hint: 'Business assets, etc.',
                onChanged: (val) => provider.otherAssets = double.tryParse(val) ?? 0,
                prefixIcon: Icons.account_balance,
                currency: provider.selectedCountry.currency,
              ),
              _buildInputField(
                label: 'Debts & Liabilities',
                hint: 'Money you owe',
                onChanged: (val) => provider.debts = double.tryParse(val) ?? 0,
                prefixIcon: Icons.remove_circle_outline,
                currency: provider.selectedCountry.currency,
                isDebt: true,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ResultScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'View Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  provider.resetInputs();
                  _formKey.currentState!.reset();
                },
                child: const Text('Reset All Inputs'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required Function(String) onChanged,
    IconData? prefixIcon,
    String? prefixIconAsset,
    String? currency,
    String? suffix,
    bool isDebt = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIconAsset != null
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    prefixIconAsset,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                )
              : (prefixIcon != null ? Icon(prefixIcon, color: isDebt ? Colors.red[400] : Colors.green[700]) : null),
          prefixText: currency != null ? '$currency ' : null,
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: onChanged,
      ),
    );
  }
}
