import 'package:flutter/material.dart';
import 'package:zakat/l10n/app_localizations.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/zakat_provider.dart';
import '../../services/local_history_service.dart';
import '../widgets/custom_widgets.dart';
import '../zakat_report_screen.dart';

class ZakatWizard extends StatefulWidget {
  const ZakatWizard({super.key});

  @override
  State<ZakatWizard> createState() => _ZakatWizardState();
}

class _ZakatWizardState extends State<ZakatWizard> {
  int _currentStep = 0;


  // Selected categories set
  final Set<_WealthEntryType> _selectedCategories = {
    _WealthEntryType.cash,
    _WealthEntryType.bank,
    _WealthEntryType.gold,
  };

  // Values stored in a map for easy access
  final Map<_WealthEntryType, double> _amounts = {};
  final Map<_WealthEntryType, int> _goldCarats = {};
  final Map<_WealthEntryType, bool> _useAppPrices = {};
  final Map<_WealthEntryType, double> _customPrices = {};
  final Map<_WealthEntryType, TextEditingController> _amountControllers = {};
  final Map<_WealthEntryType, TextEditingController> _customPriceControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize defaults
    for (var type in _WealthEntryType.values) {
      _amounts[type] = 0.0;
      _useAppPrices[type] = true;
      if (type == _WealthEntryType.gold) _goldCarats[type] = 22;
      _amountControllers[type] = TextEditingController();
      _customPriceControllers[type] = TextEditingController();
    }
  }

  @override
  void dispose() {

    for (var controller in _amountControllers.values) {
      controller.dispose();
    }
    for (var controller in _customPriceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _resetAll();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.nav_faq),
        content: Text(
          '${AppLocalizations.of(context)!.guide_step_1}\n'
          '${AppLocalizations.of(context)!.guide_step_2}\n'
          '${AppLocalizations.of(context)!.guide_step_3}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showGuideSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.guide_view, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.guide_instruction_1),
              const SizedBox(height: 6),
              Text(AppLocalizations.of(context)!.guide_instruction_2),
              const SizedBox(height: 6),
              Text(AppLocalizations.of(context)!.guide_instruction_3),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZakatProvider>();
    _syncProvider(provider);
    final currencyFormat = NumberFormat.currency(
      symbol: '${provider.selectedCountry.currency} ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, provider),
      body: Column(
        children: [
          _buildStepperHeader(provider),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildStep1(provider),
                _buildStep2(provider),
                _buildStep3(provider),
              ],
            ),
          ),
          _buildBottomSummary(provider, currencyFormat),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ZakatProvider provider) {
    return AppBar(
      backgroundColor: const Color(0xFF0A462C),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.mosque, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.app_title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  AppLocalizations.of(context)!.wizard_desc_short,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showHelpDialog,
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30),
            ),
            child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildStepperHeader(ZakatProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          _stepperItem(1, AppLocalizations.of(context)!.step_1_label, _currentStep >= 0),
          _stepperDivider(),
          _stepperItem(2, AppLocalizations.of(context)!.step_3_label, _currentStep >= 1),
          _stepperDivider(),
          _stepperItem(3, AppLocalizations.of(context)!.step_4_label, _currentStep >= 2),
        ],
      ),
    );
  }

  Widget _stepperItem(int step, String label, bool isActive) {
    final activeColor = const Color(0xFF1B5E20);
    return Expanded(
      child: InkWell(
        onTap: () {
          final targetStep = step - 1;
          if (targetStep != _currentStep) {
            setState(() => _currentStep = targetStep);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? activeColor : const Color(0xFFF1F3F4),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? activeColor : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepperDivider() {
    return Container(
      width: 20,
      height: 1,
      color: Colors.grey.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 16),
    );
  }

  Widget _buildStep1(ZakatProvider provider) {
    return ListView(
      primary: false,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.step_1_title_detailed,
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1C1E),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              IconButton(
                onPressed: _showGuideSheet,
                icon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF004D40)),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE0F2F1),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        Text(AppLocalizations.of(context)!.step_1_subtitle,
          style: TextStyle(fontSize: 14, color: Color(0xFF546E7A), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 24),
        
        ..._WealthEntryType.values.take(6).map((type) => _buildAssetCard(provider, type)),
        
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFFECEFF1), thickness: 1.5),
        ),
        
        Text(AppLocalizations.of(context)!.liabilities_title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF263238)),
        ),
        const SizedBox(height: 12),
        
        _buildAssetCard(provider, _WealthEntryType.receivable),
        _buildAssetCard(provider, _WealthEntryType.debt),

        const SizedBox(height: 24),
        _buildInfoBox(provider),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAssetCard(ZakatProvider provider, _WealthEntryType type) {
    bool isSelected = _selectedCategories.contains(type);
    bool isExpanded = type == _WealthEntryType.gold || type == _WealthEntryType.silver;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF004D40) : const Color(0xFFECEFF1),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: const Color(0xFF004D40).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ] : [],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedCategories.add(type);
                        } else {
                          _selectedCategories.remove(type);
                        }
                      });
                    },
                    activeColor: const Color(0xFF004D40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    side: const BorderSide(color: Color(0xFFCFD8DC), width: 1.5),
                  ),
                ),
                _buildAssetIcon(type),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleFor(provider, type),
                        style: TextStyle(
                          fontWeight: FontWeight.w800, 
                          fontSize: 16, 
                          color: isSelected ? const Color(0xFF1A1C1E) : const Color(0xFF546E7A)
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitleFor(provider, type),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF78909C), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (!isExpanded && isSelected) _buildSmallInputField(provider, type),
                if (isExpanded && isSelected) const Icon(Icons.keyboard_arrow_down, color: Color(0xFF004D40)),
              ],
            ),
          ),
          if (isSelected && isExpanded) _buildExpandedMetalSection(provider, type),
        ],
      ),
    );
  }

  Widget _buildAssetIcon(_WealthEntryType type) {
    Color bgColor;
    IconData? icon;
    String? assetPath;
    switch (type) {
      case _WealthEntryType.cash:
        bgColor = const Color(0xFFE8F5E9);
        icon = Icons.money;
        break;
      case _WealthEntryType.bank:
        bgColor = const Color(0xFFE3F2FD);
        icon = Icons.account_balance;
        break;
      case _WealthEntryType.gold:
        bgColor = const Color(0xFFFFF8E1);
        assetPath = 'assets/icons/gold.png';
        break;
      case _WealthEntryType.silver:
        bgColor = const Color(0xFFF5F5F5);
        assetPath = 'assets/icons/silver.png';
        break;
      case _WealthEntryType.business:
        bgColor = const Color(0xFFF3E5F5);
        icon = Icons.store;
        break;
      case _WealthEntryType.investment:
        bgColor = const Color(0xFFE8F5E9);
        icon = Icons.trending_up;
        break;
      case _WealthEntryType.receivable:
        bgColor = const Color(0xFFE6F4EA);
        icon = Icons.call_received;
        break;
      case _WealthEntryType.debt:
        bgColor = const Color(0xFFFFEBEE);
        icon = Icons.money_off_csred_outlined;
        break;
      default:
        bgColor = Colors.grey[100]!;
        icon = Icons.help;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: assetPath != null
          ? Image.asset(
              assetPath,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            )
          : Icon(
              icon,
              color: Colors.black.withOpacity(0.7),
              size: 20,
            ),
    );
  }

  Widget _buildSmallInputField(ZakatProvider provider, _WealthEntryType type) {
    return SizedBox(
      width: 140,
      height: 40,
      child: TextField(
        controller: _amountControllers[type],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixText: '৳ ',
          hintText: '০',
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
        ),
        onChanged: (val) => _amounts[type] = double.tryParse(val) ?? 0,
      ),
    );
  }

  Widget _buildExpandedMetalSection(ZakatProvider provider, _WealthEntryType type) {
    final bool isGold = type == _WealthEntryType.gold;
    final List<MetalItem> items = isGold ? provider.goldItems : provider.silverItems;

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isGold ? AppLocalizations.of(context)!.gold_details : AppLocalizations.of(context)!.silver_details,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF263238)),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 14, color: Colors.grey),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showAddMetalItemSheet(provider, isGold),
                icon: const Icon(Icons.add, size: 14),
                label: Text(isGold ? AppLocalizations.of(context)!.add_new_gold : AppLocalizations.of(context)!.add_new_silver),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B5E20),
                  side: const BorderSide(color: Color(0xFF81C784)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F9F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8F5E9)),
              ),
              child: Column(
                children: [
                  Text(
                    isGold ? AppLocalizations.of(context)!.no_gold_added : AppLocalizations.of(context)!.no_silver_added,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isGold ? AppLocalizations.of(context)!.empty_gold_desc : AppLocalizations.of(context)!.empty_silver_desc,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF4C6A58)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                String unitLocal = item.unit == 'bhori' ? AppLocalizations.of(context)!.unit_bhori : 
                                  item.unit == 'ana' ? AppLocalizations.of(context)!.unit_ana :
                                  item.unit == 'ounce' ? AppLocalizations.of(context)!.unit_ounce :
                                  AppLocalizations.of(context)!.unit_gram;
                String title = '${item.weight} $unitLocal';
                if (isGold) {
                  title = '${item.purity == 0 ? AppLocalizations.of(context)!.carat_trad : '${item.purity} ${AppLocalizations.of(context)!.carat_label}'}, $title';
                } else {
                  final purity = item.purity ?? 24;
                  String purityLabel = '';
                  if (purity == 24) purityLabel = AppLocalizations.of(context)!.silver_24k;
                  else if (purity == 22) purityLabel = AppLocalizations.of(context)!.silver_22k;
                  else if (purity == 21) purityLabel = AppLocalizations.of(context)!.silver_21k;
                  else if (purity == 19) purityLabel = AppLocalizations.of(context)!.silver_19k;
                  else purityLabel = '$purity K';
                  title = '$purityLabel, $title';
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: () {
                          if (isGold) {
                            provider.removeGoldItem(item.id);
                          } else {
                            provider.removeSilverItem(item.id);
                          }
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                );
              },
            ),
            
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _useAppPrices[type] ?? true,
                  onChanged: (v) {
                    setState(() => _useAppPrices[type] = v ?? true);
                    _syncProvider(provider);
                  },
                  activeColor: const Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: Text(
                  AppLocalizations.of(context)!.use_custom_prices, 
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        '${AppLocalizations.of(context)!.market_rates}: ${_getMarketPrice(provider, type)} / ${provider.unitNameLabel}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.info_outline, size: 12, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          if (!(_useAppPrices[type] ?? true)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFECB3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isGold ? AppLocalizations.of(context)!.custom_gold_price : AppLocalizations.of(context)!.custom_silver_price,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF57F17)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    height: 36,
                    child: TextField(
                      controller: _customPriceControllers[type],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixText: '${provider.selectedCountry.currency} ',
                        hintText: '0',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                      ),
                      onChanged: (val) {
                        _customPrices[type] = double.tryParse(val) ?? 0.0;
                        _syncProvider(provider);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getMarketPrice(ZakatProvider provider, _WealthEntryType type) {
    if (type == _WealthEntryType.gold) return provider.effectiveGoldPricePerGram.toStringAsFixed(0);
    if (type == _WealthEntryType.silver) return provider.effectiveSilverPricePerGram.toStringAsFixed(0);
    return '0';
  }



  Widget _buildInfoBox(ZakatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_outlined, color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.edu_title, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.wizard_info_text,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(ZakatProvider provider, NumberFormat format) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.wealth_summary, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _summaryItem(AppLocalizations.of(context)!.total_assets, format.format(provider.totalAssets)),
                        _verticalDivider(),
                        _summaryItem(AppLocalizations.of(context)!.total_liabilities, format.format(provider.debts)),
                        _verticalDivider(),
                        _summaryItem(AppLocalizations.of(context)!.net_wealth, format.format(provider.netWealth)),
                        _verticalDivider(),
                        _summaryItem(AppLocalizations.of(context)!.zakat_due, format.format(provider.zakatDue), isHighlighted: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _currentStep == 2 ? () => _saveToHistory(provider) : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 1
                                ? (AppLocalizations.of(context)!.calculate_now)
                                : _currentStep == 2
                                    ? AppLocalizations.of(context)!.finish_save
                                    : (AppLocalizations.of(context)!.next_step),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentStep == 1
                                ? Icons.calculate
                                : _currentStep == 2
                                    ? Icons.bookmark_added_rounded
                                    : Icons.arrow_forward,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _resetAll,
                      icon: const Icon(Icons.refresh, size: 16, color: Colors.black54),
                      label: Text(
                        _currentStep == 2
                            ? AppLocalizations.of(context)!.new_calc
                            : AppLocalizations.of(context)!.reset,
                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetAll() {
    setState(() {
      _currentStep = 0;
      _amounts.clear();
      _customPrices.clear();
      _selectedCategories.clear();
      _selectedCategories.addAll({_WealthEntryType.cash, _WealthEntryType.bank, _WealthEntryType.gold});
      for (var type in _WealthEntryType.values) {
        _amounts[type] = 0.0;
        _useAppPrices[type] = true;
        _amountControllers[type]?.clear();
        _customPriceControllers[type]?.clear();
      }
    });
    context.read<ZakatProvider>().resetInputs();
  }

  Widget _summaryItem(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isHighlighted ? const Color(0xFF2E7D32) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildStep2(ZakatProvider provider) {
    final money = NumberFormat.currency(symbol: '৳ ', decimalDigits: 2);
    final netWealth = provider.netWealth;
    final threshold = provider.selectedNisabThreshold;
    final isAboveNisab = netWealth >= threshold;

    return ListView(
      primary: false,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '2. ${AppLocalizations.of(context)!.step_3_title}',
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1E),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFECEFF1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.analytics_outlined, color: Color(0xFF004D40), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.nisab_threshold,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1A1C1E)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.nisab_method,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF546E7A)),
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildNisabOption(
                        label: AppLocalizations.of(context)!.silver_nisab_option,
                        subLabel: AppLocalizations.of(context)!.silver_nisab_weight,
                        selected: provider.nisabMethod == 'silver',
                        onTap: () => provider.setNisabMethod('silver'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNisabOption(
                        label: AppLocalizations.of(context)!.gold_nisab_option,
                        subLabel: AppLocalizations.of(context)!.gold_nisab_weight,
                        selected: provider.nisabMethod == 'gold',
                        onTap: () => provider.setNisabMethod('gold'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildHawlStatusRow(provider),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F4)),
              ),
              _buildSummaryRowBn(AppLocalizations.of(context)!.total_assets, money.format(provider.totalAssets)),
              const SizedBox(height: 16),
              _buildSummaryRowBn(AppLocalizations.of(context)!.total_liabilities, '- ${money.format(provider.debts)}', valueColor: const Color(0xFFD32F2F)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF004D40).withOpacity(0.1)),
                ),
                child: _buildSummaryRowBn(
                  AppLocalizations.of(context)!.net_wealth,
                  money.format(netWealth),
                  isBold: true,
                  valueColor: const Color(0xFF004D40),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isAboveNisab 
                ? [const Color(0xFF004D40), const Color(0xFF006D41)]
                : [const Color(0xFFD32F2F), const Color(0xFFB71C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isAboveNisab ? const Color(0xFF004D40) : const Color(0xFFD32F2F)).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.nisab_threshold,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        money.format(threshold),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAboveNisab ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.white24, height: 1),
              ),
              Row(
                children: [
                  Icon(
                    isAboveNisab ? Icons.check_circle_outline : Icons.error_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAboveNisab 
                        ? AppLocalizations.of(context)!.eligible_desc
                        : AppLocalizations.of(context)!.not_eligible_desc,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStep3(ZakatProvider provider) {
    final money = NumberFormat.currency(symbol: '${provider.selectedCountry.currency} ', decimalDigits: 0);
    final now = DateFormat('dd MMM yyyy').format(DateTime.now());
    
    return ListView(
      primary: false,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 16),
        
        // Success Header
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
                ),
                child: const Icon(Icons.check_rounded, size: 48, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.result_title,
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B5E20),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.wizard_desc,
                style: TextStyle(fontSize: 15, color: Color(0xFF546E7A), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Massive Hero Result Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF004D40), Color(0xFF006D41)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF004D40).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.zakat_due,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  money.format(provider.zakatDue),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.zakat_rate_label,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Details Breakdown Card
        ProfessionalCard(
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.wealth_summary,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF263238)),
              ),
              const SizedBox(height: 20),
              _buildResultRow(AppLocalizations.of(context)!.net_wealth, money.format(provider.netWealth)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: Color(0xFFECEFF1)),
              ),
              _buildResultRow(AppLocalizations.of(context)!.nisab_method, provider.nisabMethod == 'gold' ? AppLocalizations.of(context)!.gold_nisab : AppLocalizations.of(context)!.silver_nisab),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: Color(0xFFECEFF1)),
              ),
              _buildResultRow(AppLocalizations.of(context)!.last_updated, now),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Tazkiyah Note
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F9F6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6EBDE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.wb_twilight, color: Color(0xFF388E3C), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.result_title,
                      style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1B5E20), fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.tazkiyah_note,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF455A64), height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ZakatReportScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                label: const Text('Export', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F7F9),
                  foregroundColor: const Color(0xFF263238),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFCFD8DC)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildNisabOption({
    required String label,
    required String subLabel,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF1FBF5) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF5DBA84) : const Color(0xFFE2E5E3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? const Color(0xFF0D8C4E) : const Color(0xFFA9B2AD),
                ),
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFF0D8C4E),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  Text(subLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF7D8782))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHawlStatusRow(ZakatProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF2E7D32)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.hawl_completed,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1C1E)),
                    ),
                  ),
                  Switch.adaptive(
                    value: provider.hawlCompleted,
                    activeColor: const Color(0xFF81C784),
                    onChanged: provider.setHawlCompleted,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.hawl_pending_desc,
                style: const TextStyle(fontSize: 13, color: Color(0xFF546E7A), height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRowBn(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 15,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF1C2521),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1C2521),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? const Color(0xFF263238) : const Color(0xFF546E7A),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: FontWeight.w800,
            color: valueColor ?? const Color(0xFF263238),
          ),
        ),
      ],
    );
  }



  Future<void> _showAddMetalItemSheet(ZakatProvider provider, bool isGold) async {
    double weight = 0;
    String unit = provider.usesBhoriUnit ? 'bhori' : 'gram';
    int purity = isGold ? 22 : 24; // default
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
              left: 20, right: 20, top: 20
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGold ? AppLocalizations.of(context)!.add_new_gold : AppLocalizations.of(context)!.add_new_silver,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.weight_label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          TextField(
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: '0',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (val) => weight = double.tryParse(val) ?? 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Unit', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: unit,
                              underline: const SizedBox(),
                              items: (provider.selectedLanguageCode == 'tr' ? ['gram', 'ounce'] : ['gram', 'bhori', 'ana']).map((u) {
                                String label = u;
                                if (u == 'bhori') label = AppLocalizations.of(context)!.unit_bhori;
                                if (u == 'ana') label = AppLocalizations.of(context)!.unit_ana;
                                if (u == 'gram') label = AppLocalizations.of(context)!.unit_gram;
                                if (u == 'ounce') label = AppLocalizations.of(context)!.unit_ounce;
                                return DropdownMenuItem(value: u, child: Text(label, style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setModalState(() => unit = v);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isGold ? AppLocalizations.of(context)!.carat_label : AppLocalizations.of(context)!.silver_purity_breakdown,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: purity,
                    underline: const SizedBox(),
                    items: isGold
                        ? [
                            DropdownMenuItem(value: 24, child: Text('24 ${AppLocalizations.of(context)!.carat_label}')),
                            DropdownMenuItem(value: 22, child: Text('22 ${AppLocalizations.of(context)!.carat_label}')),
                            DropdownMenuItem(value: 21, child: Text('21 ${AppLocalizations.of(context)!.carat_label}')),
                            DropdownMenuItem(value: 18, child: Text('18 ${AppLocalizations.of(context)!.carat_label}')),
                            DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.carat_trad)),
                          ]
                        : [
                            DropdownMenuItem(value: 24, child: Text(AppLocalizations.of(context)!.silver_24k)),
                            DropdownMenuItem(value: 22, child: Text(AppLocalizations.of(context)!.silver_22k)),
                            DropdownMenuItem(value: 21, child: Text(AppLocalizations.of(context)!.silver_21k)),
                            DropdownMenuItem(value: 19, child: Text(AppLocalizations.of(context)!.silver_19k)),
                          ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => purity = v);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (weight <= 0) return;
                      final item = MetalItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        weight: weight,
                        unit: unit,
                        purity: purity,
                      );
                      if (isGold) {
                        provider.addGoldItem(item);
                      } else {
                        provider.addSilverItem(item);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D40),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(AppLocalizations.of(context)!.add_item),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  String _summaryShareText(ZakatProvider provider) {
    final f = NumberFormat.currency(symbol: '${provider.selectedCountry.currency} ', decimalDigits: 2);
    final loc = AppLocalizations.of(context)!;
    return '${loc.result_title}\n'
        '${loc.total_assets}: ${f.format(provider.totalAssets)}\n'
        '${loc.total_liabilities}: ${f.format(provider.debts)}\n'
        '${loc.net_wealth}: ${f.format(provider.netWealth)}\n'
        '${loc.zakat_due}: ${f.format(provider.zakatDue)}\n'
        '${loc.nisab_method}: ${provider.nisabMethod == 'gold' ? loc.gold_nisab : loc.silver_nisab}';
  }

  Future<void> _shareSummary(ZakatProvider provider) async {
    final text = _summaryShareText(provider);
    await Share.share(text, subject: AppLocalizations.of(context)!.result_title);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.finish_save)),
    );
  }

  Future<void> _saveToHistory(ZakatProvider provider) async {
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
        'investments': provider.investments,
        'business_assets': provider.businessAssets,
        'receivables': provider.receivables,
        'debts': provider.debts,
        'other_assets': provider.otherAssets,
        'nisab_method': provider.nisabMethod,
        'hawl_completed': provider.hawlCompleted,
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.finish_save)),
    );
    Navigator.of(context).pop();
  }

  void _syncProvider(ZakatProvider provider) {
    double cash = 0;
    double bank = 0;
    double investments = 0;
    double businessAssets = 0;
    double receivables = 0;
    double debts = 0;
    double goldW = 0;
    double silverW = 0;
    double? customGoldPrice;
    double? customSilverPrice;

    for (var type in _selectedCategories) {
      double amt = _amounts[type] ?? 0;
      switch (type) {
        case _WealthEntryType.cash:
          cash += amt;
          break;
        case _WealthEntryType.bank:
          bank += amt;
          break;
        case _WealthEntryType.gold:
          goldW = amt;
          if (!(_useAppPrices[type] ?? true)) {
            customGoldPrice = _customPrices[type];
          }
          break;
        case _WealthEntryType.silver:
          silverW = amt;
          if (!(_useAppPrices[type] ?? true)) {
            customSilverPrice = _customPrices[type];
          }
          break;
        case _WealthEntryType.investment:
          investments += amt;
          break;
        case _WealthEntryType.business:
          businessAssets += amt;
          break;
        case _WealthEntryType.receivable:
          receivables += amt;
          break;
        case _WealthEntryType.debt:
          debts += amt;
          break;
      }
    }

    provider.cash = cash;
    provider.bank = bank;
    provider.investments = investments;
    provider.businessAssets = businessAssets;
    provider.receivables = receivables;
    provider.debts = debts;
    provider.goldWeight = goldW;
    provider.silverWeight = silverW;
    provider.otherAssets = 0.0;

    provider.setCalculationPriceOverrides(
      goldPerGram: customGoldPrice,
      silverPerGram: customSilverPrice,
      notify: false,
    );
  }

  String _titleFor(ZakatProvider provider, _WealthEntryType type) {
    switch (type) {
      case _WealthEntryType.cash: return AppLocalizations.of(context)!.cash_entry;
      case _WealthEntryType.bank: return AppLocalizations.of(context)!.bank_entry;
      case _WealthEntryType.gold: return AppLocalizations.of(context)!.gold_entry;
      case _WealthEntryType.silver: return AppLocalizations.of(context)!.silver_entry;
      case _WealthEntryType.investment: return AppLocalizations.of(context)!.investments_entry;
      case _WealthEntryType.business: return AppLocalizations.of(context)!.business_entry;
      case _WealthEntryType.receivable: return AppLocalizations.of(context)!.receivables_entry;
      case _WealthEntryType.debt: return AppLocalizations.of(context)!.debt_entry;
      default: return '';
    }
  }

  String _subtitleFor(ZakatProvider provider, _WealthEntryType type) {
    switch (type) {
      case _WealthEntryType.cash: return AppLocalizations.of(context)!.cash_home;
      case _WealthEntryType.bank: return AppLocalizations.of(context)!.bank_accounts;
      case _WealthEntryType.gold: return AppLocalizations.of(context)!.gold_weight;
      case _WealthEntryType.silver: return AppLocalizations.of(context)!.silver_weight;
      case _WealthEntryType.investment: return AppLocalizations.of(context)!.stocks;
      case _WealthEntryType.business: return AppLocalizations.of(context)!.business_assets;
      default: return '';
    }
  }
}

enum _WealthEntryType {
  cash,
  bank,
  gold,
  silver,
  business,
  investment,
  receivable,
  debt,
}
