import 'package:flutter/material.dart';
import 'package:zakat/l10n/app_localizations.dart';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/zakat_provider.dart';
import '../services/local_history_service.dart';
import 'widgets/custom_widgets.dart';
import 'wizard/animal_wizard.dart';
import 'wizard/zakat_wizard.dart';
import 'metal_details_screen.dart';
import 'zakat_report_screen.dart';
import 'history_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final LocalHistoryService _historyService = LocalHistoryService();
  String _activeHistoryFilter = 'all';
  DateTimeRange? _selectedDateRange;
  String _activeDatePreset = 'all';


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZakatProvider>();
    final currencyFormat = NumberFormat.currency(
      symbol: '${provider.selectedCountry.currency} ',
      decimalDigits: 2,
    );
    final overlayStyle = _currentIndex == 0 ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),
        body: _buildBody(context, provider, currencyFormat),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton.extended(
                onPressed: provider.isLoading ? null : () => provider.manualRefreshPrices(),
                backgroundColor: const Color(0xFF0A462C),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(AppLocalizations.of(context)!.manual_refresh),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              backgroundColor: Colors.transparent,
              selectedItemColor: const Color(0xFF0A462C),
              unselectedItemColor: const Color(0xFF9AA6A0),
              items: [
                BottomNavigationBarItem(
                  icon: BouncingIcon(
                    iconData: Icons.home_outlined,
                    isSelected: _currentIndex == 0,
                    color: const Color(0xFF9AA6A0),
                  ),
                  activeIcon: BouncingIcon(
                    iconData: Icons.home,
                    isSelected: _currentIndex == 0,
                    color: const Color(0xFF0A462C),
                  ),
                  label: AppLocalizations.of(context)!.nav_home,
                ),
                BottomNavigationBarItem(
                  icon: BouncingIcon(
                    iconData: Icons.calculate_outlined,
                    isSelected: _currentIndex == 1,
                    color: const Color(0xFF9AA6A0),
                  ),
                  activeIcon: BouncingIcon(
                    iconData: Icons.calculate,
                    isSelected: _currentIndex == 1,
                    color: const Color(0xFF0A462C),
                  ),
                  label: AppLocalizations.of(context)!.nav_calculator,
                ),
                BottomNavigationBarItem(
                  icon: BouncingIcon(
                    iconData: Icons.history,
                    isSelected: _currentIndex == 2,
                    color: const Color(0xFF9AA6A0),
                  ),
                  activeIcon: BouncingIcon(
                    iconData: Icons.history,
                    isSelected: _currentIndex == 2,
                    color: const Color(0xFF0A462C),
                  ),
                  label: AppLocalizations.of(context)!.nav_history,
                ),
                BottomNavigationBarItem(
                  icon: BouncingIcon(
                    iconData: Icons.quiz_outlined,
                    isSelected: _currentIndex == 3,
                    color: const Color(0xFF9AA6A0),
                  ),
                  activeIcon: BouncingIcon(
                    iconData: Icons.quiz,
                    isSelected: _currentIndex == 3,
                    color: const Color(0xFF0A462C),
                  ),
                  label: AppLocalizations.of(context)!.nav_faq,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ZakatProvider provider, NumberFormat format) {
    return FadeIndexedStack(
      index: _currentIndex,
      children: [
        _KeepAliveTabWrapper(child: _buildHomeTab(context, provider, format)),
        _KeepAliveTabWrapper(child: _buildCalculatorTab(context, provider)),
        _KeepAliveTabWrapper(child: _buildHistoryTab(context, provider, format)),
        _KeepAliveTabWrapper(child: _buildFaqTab(context, provider)),
      ],
    );
  }

  Widget _buildHomeTab(BuildContext context, ZakatProvider provider, NumberFormat format) {
    return SafeArea(
      top: false,
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHomeHeader(context, provider),
            Transform.translate(
              offset: const Offset(0, -26),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildMarketRates(context, provider, format),
                    const SizedBox(height: 14),
                    _buildNisabSection(context, provider, format),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A462C) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, ZakatProvider provider, NumberFormat format) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.nav_history, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0A462C),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => HistoryFilterBottomSheet(
                  initialRange: _selectedDateRange,
                  initialPreset: _activeDatePreset,
                  onApply: (data) {
                    setState(() {
                      _activeDatePreset = data['preset'] as String;
                      _selectedDateRange = data['range'] as DateTimeRange?;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyService.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0A462C)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A462C).withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history_rounded, size: 72, color: Color(0xFF0A462C)),
                  ),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context)!.nav_history, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E2923))),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.history_empty, style: const TextStyle(fontSize: 15, color: Color(0xFF7D8984))),
                ],
              ),
            );
          }

          final filteredHistory = history.where((item) {
            final date = DateTime.parse(item['calculation_date'] as String);
            
            final isDraft = item['zakat_due'] == 0.0;
            bool statusMatch = true;
            if (_activeHistoryFilter == 'completed') {
              statusMatch = !isDraft;
            } else if (_activeHistoryFilter == 'draft') {
              statusMatch = isDraft;
            }

            bool dateMatch = true;
            if (_selectedDateRange != null) {
              final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
              final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
              dateMatch = date.isAfter(start) && date.isBefore(end);
            }

            return statusMatch && dateMatch;
          }).toList();

          final Map<String, List<Map<String, dynamic>>> grouped = {};
          final monthsBn = ['জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
          final monthsEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
          final isBn = Localizations.localeOf(context).languageCode == 'bn';
          final months = isBn ? monthsBn : monthsEn;
          
          final engToBnDigits = {'0':'০', '1':'১', '2':'২', '3':'৩', '4':'৪', '5':'৫', '6':'৬', '7':'৭', '8':'৮', '9':'৯'};
          
          String toBnNumber(String input) {
            if (!isBn) return input;
            return input.split('').map((c) => engToBnDigits[c] ?? c).join('');
          }

          for (var item in filteredHistory) {
            final date = DateTime.parse(item['calculation_date'] as String);
            final monthStr = months[date.month - 1];
            final yearStr = toBnNumber(date.year.toString());
            final groupKey = '$monthStr $yearStr';
            
            if (!grouped.containsKey(groupKey)) {
              grouped[groupKey] = [];
            }
            grouped[groupKey]!.add(item);
          }

          return Column(
            children: [
              // Filters
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildFilterChip(
                                AppLocalizations.of(context)!.history_filter_all,
                                _activeHistoryFilter == 'all',
                                () => setState(() => _activeHistoryFilter = 'all'),
                              ),
                            ),
                            Expanded(
                              child: _buildFilterChip(
                                AppLocalizations.of(context)!.history_filter_completed,
                                _activeHistoryFilter == 'completed',
                                () => setState(() => _activeHistoryFilter = 'completed'),
                              ),
                            ),
                            Expanded(
                              child: _buildFilterChip(
                                AppLocalizations.of(context)!.history_filter_draft,
                                _activeHistoryFilter == 'draft',
                                () => setState(() => _activeHistoryFilter = 'draft'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedDateRange != null)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      InputChip(
                        label: Text(
                          _activeDatePreset == 'thisYear'
                              ? AppLocalizations.of(context)!.date_filter_this_year
                              : _activeDatePreset == 'lastYear'
                                  ? AppLocalizations.of(context)!.date_filter_last_year
                                  : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0A462C), fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFFE8F5E9),
                        deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF0A462C)),
                        onDeleted: () {
                          setState(() {
                            _selectedDateRange = null;
                            _activeDatePreset = 'all';
                          });
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: const Color(0xFF0A462C).withOpacity(0.2)),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: filteredHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A462C).withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _activeHistoryFilter == 'completed'
                                    ? Icons.done_all_rounded
                                    : Icons.edit_note_rounded,
                                size: 72,
                                color: const Color(0xFF0A462C),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _activeHistoryFilter == 'completed'
                                  ? AppLocalizations.of(context)!.history_no_completed
                                  : AppLocalizations.of(context)!.history_no_drafts,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2923)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: grouped.keys.length,
                        itemBuilder: (context, index) {
                          final groupKey = grouped.keys.elementAt(index);
                          final items = grouped[groupKey]!;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12, top: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(groupKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E2923))),
                                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                  ],
                                ),
                              ),
                              ...items.map((item) {
                                final date = DateTime.parse(item['calculation_date'] as String);
                                final isDraft = item['zakat_due'] == 0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HistoryDetailsScreen(item: item, format: format),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.grey.withOpacity(0.05)),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isDraft ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: isDraft ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
                                            ),
                                            child: Icon(isDraft ? Icons.edit_note : Icons.calculate_outlined, color: isDraft ? Colors.orange : const Color(0xFF0A462C), size: 24),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Zakah Calculation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                const SizedBox(height: 4),
                                                Text(DateFormat("dd MMM yyyy, hh:mm a").format(date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text('${item['currency']} ${format.format(item['zakat_due'] as num)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A462C))),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isDraft ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: isDraft ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3)),
                                                ),
                                                child: Text(isDraft ? AppLocalizations.of(context)!.history_filter_draft : AppLocalizations.of(context)!.history_filter_completed, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDraft ? Colors.orange[800] : const Color(0xFF0A462C))),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalculatorTab(BuildContext context, ZakatProvider provider) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.nav_calculator), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            AppLocalizations.of(context)!.calculator_intro,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          _buildCategoryGrid(context, provider),
        ],
      ),
    );
  }

  Widget _buildFaqTab(BuildContext context, ZakatProvider provider) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.nav_faq), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildEduItem(AppLocalizations.of(context)!.edu_q1, AppLocalizations.of(context)!.edu_a1),
          _buildEduItem(AppLocalizations.of(context)!.edu_q2, AppLocalizations.of(context)!.edu_a2),
        ],
      ),
    );
  }

  Widget _buildEduItem(String q, String a) {
    return ExpansionTile(
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(a, style: const TextStyle(height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildContactButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, ZakatProvider provider) {
    return Column(
      children: [
        _buildCategoryCard(
          context,
          AppLocalizations.of(context)!.category_securities,
          Icons.account_balance_wallet,
          const Color(0xFF004D40),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZakatWizard())),
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          context,
          AppLocalizations.of(context)!.category_animals,
          Icons.pets,
          const Color(0xFFC5A059),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnimalWizard())),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: ProfessionalCard(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeHeader(BuildContext context, ZakatProvider provider) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 56),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF052A1A), Color(0xFF0A462C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: 18 + statusBarHeight,
            child: const Opacity(
              opacity: 0.12,
              child: Icon(Icons.mosque_rounded, size: 150, color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCurrencySwitcher(provider),
                  _buildLanguageSwitcher(provider),
                ],
              ),
              const SizedBox(height: 26),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _getGreeting(provider.selectedLanguageCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.wizard_desc,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySwitcher(ZakatProvider provider) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Country>(
        value: provider.selectedCountry,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
        dropdownColor: const Color(0xFF0A462C),
        onChanged: (Country? newValue) {
          if (newValue != null) provider.setCountry(newValue);
        },
        items: provider.countries.map<DropdownMenuItem<Country>>((Country country) {
          return DropdownMenuItem<Country>(
            value: country,
            child: Text(country.currency, style: const TextStyle(color: Colors.white, fontSize: 14)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguageSwitcher(ZakatProvider provider) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: provider.selectedLanguageCode,
        icon: const Icon(Icons.language, color: Colors.white, size: 18),
        dropdownColor: const Color(0xFF0A462C),
        onChanged: (String? newValue) {
          if (newValue != null) provider.setLanguage(newValue);
        },
        items: provider.supportedLanguageCodes.map<DropdownMenuItem<String>>((String code) {
          return DropdownMenuItem<String>(
            value: code,
            child: Text(provider.languageLabel(code), style: const TextStyle(color: Colors.white, fontSize: 14)),
          );
        }).toList(),
      ),
    );
  }

  String _getGreeting(String lang) {
    if (lang == 'bn') {
      return 'আছ ছালামু আলাইকুম ওয়া রহমাতুল্লাহ';
    }
    if (lang == 'tr') {
      return 'Es-selamu aleykum ve rahmetullah';
    }
    return 'Assalamu Alaikum wa Rahmatullah';
  }

  String _getMarketSourceLabel(BuildContext context, String source) {
    final normalized = source.trim().toLowerCase();

    if (normalized.contains('bajus')) {
      return AppLocalizations.of(context)!.market_source_bajus;
    }
    if (normalized.contains('ibja')) {
      return AppLocalizations.of(context)!.market_source_ibja;
    }
    if (normalized.contains('harem')) {
      return AppLocalizations.of(context)!.market_source_harem;
    }
    if (normalized.contains('altin.in') || normalized.contains('altin')) {
      return AppLocalizations.of(context)!.market_source_altin_in;
    }
    return AppLocalizations.of(context)!.market_source_gold_api;
  }

  Widget _buildMarketRates(BuildContext context, ZakatProvider provider, NumberFormat format) {
    final updatedAt = _formatUpdatedAt(provider.marketUpdatedLabel);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildRateCard(
                title: AppLocalizations.of(context)!.gold_24k,
                value: format.format(provider.pureGoldPriceDisplay),
                unit: provider.perUnitLabel,
                tone: const [Color(0xFFFFF2D3), Colors.white],
                isGold: true,
                changePercent: provider.goldChangePercent,
                trendPoints: provider.goldTrendHistory,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRateCard(
                title: AppLocalizations.of(context)!.silver,
                value: format.format(provider.silverPriceDisplay),
                unit: provider.perUnitLabel,
                tone: const [Color(0xFFF2F3F4), Colors.white],
                isGold: false,
                changePercent: provider.silverChangePercent,
                trendPoints: provider.silverTrendHistory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.schedule, size: 13, color: Color(0xFF8C9793)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${AppLocalizations.of(context)!.last_updated}: $updatedAt${provider.marketIsCached ? ' (${AppLocalizations.of(context)!.cached_label})' : ''}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF8C9793)),
              ),
            ),
            Row(
              children: [
                Text(
                  _getMarketSourceLabel(context, provider.marketSource),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF7B8682), fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 13, color: Color(0xFF78C79D)),
              ],
            ),
          ],
        ),
        if (provider.marketFetchFailed)          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.fetch_failed_message,
                style: const TextStyle(fontSize: 11, color: Color(0xFFB3261E)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRateCard({
    required String title,
    required String value,
    required String unit,
    required List<Color> tone,
    required bool isGold,
    required double changePercent,
    required List<double> trendPoints,
  }) {
    final trendColor = isGold ? const Color(0xFFD6A33D) : const Color(0xFFC3C9D0);
    final percentColor = changePercent >= 0 ? const Color(0xFF1E9E68) : const Color(0xFFE14D4D);
    final trendIcon = changePercent >= 0 ? Icons.trending_up : Icons.trending_down;
    final sign = changePercent >= 0 ? '+' : '-';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MetalDetailsScreen(isGold: isGold),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: tone, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isGold ? const Color(0xFFF7EED8) : const Color(0xFFEDEFF2),
            ),
            padding: const EdgeInsets.all(6),
            child: ClipOval(
              child: Image.asset(
                isGold ? 'assets/icons/gold.png' : 'assets/icons/silver.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF5F6763))),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 2),
          Text(unit, style: const TextStyle(fontSize: 11, color: Color(0xFF7D8984))),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(trendIcon, size: 14, color: percentColor),
              const SizedBox(width: 4),
              Text(
                '$sign${changePercent.abs().toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: percentColor),
              ),
            ],
          ),
          Text(
            _dailyChangeLabel(),
            style: const TextStyle(fontSize: 10, color: Color(0xFF8C9793)),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 86,
              height: 22,
              child: CustomPaint(
                painter: _SparklinePainter(points: trendPoints, color: trendColor),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  String _dailyChangeLabel() {
    return AppLocalizations.of(context)!.compared_to_yesterday;
  }



  String _formatUpdatedAt(String rawValue) {
    if (rawValue == '--') return '--';
    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) return rawValue;
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
  }

  Widget _buildNisabSection(BuildContext context, ZakatProvider provider, NumberFormat format) {
    return ProfessionalCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.nisab_threshold,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 1),
                child: Text(AppLocalizations.of(context)!.nav_calculator),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildNisabValueTile(
            title: AppLocalizations.of(context)!.silver_nisab,
            amount: format.format(provider.silverNisabThreshold),
            subtitle: '612.36g ${AppLocalizations.of(context)!.silver}',
            highlighted: true,
            badge: AppLocalizations.of(context)!.recommended,
          ),
          const SizedBox(height: 10),
          _buildNisabValueTile(
            title: AppLocalizations.of(context)!.gold_nisab,
            amount: format.format(provider.goldNisabThreshold),
            subtitle: '87.5g ${AppLocalizations.of(context)!.gold_24k}',
            highlighted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNisabValueTile({
    required String title,
    required String amount,
    required String subtitle,
    required bool highlighted,
    String? badge,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted ? const Color(0xFFD9ECE2) : const Color(0xFFE5ECE8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF475650), fontWeight: FontWeight.w600),
                ),
              ),
              if (badge != null && badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F4ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF2A7D51), fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF7B8682)),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;

    final clean = points.where((e) => e.isFinite && e > 0).toList(growable: false);
    if (clean.length < 2) {
      final flat = Path()
        ..moveTo(0, size.height * 0.75)
        ..lineTo(size.width, size.height * 0.75);
      canvas.drawPath(flat, paint);
      return;
    }

    final minV = clean.reduce((a, b) => a < b ? a : b);
    final maxV = clean.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs();
    final safeRange = range < 0.000001 ? 1.0 : range;
    final stepX = size.width / (clean.length - 1);

    final path = Path();
    for (int i = 0; i < clean.length; i++) {
      final x = i * stepX;
      final normalized = (clean[i] - minV) / safeRange;
      final y = size.height - (normalized * (size.height * 0.85) + size.height * 0.08);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    if (oldDelegate.color != color) return true;
    if (oldDelegate.points.length != points.length) return true;
    for (int i = 0; i < points.length; i++) {
      if (oldDelegate.points[i] != points[i]) return true;
    }
    return false;
  }
}

class _KeepAliveTabWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveTabWrapper({required this.child});

  @override
  State<_KeepAliveTabWrapper> createState() => _KeepAliveTabWrapperState();
}

class _KeepAliveTabWrapperState extends State<_KeepAliveTabWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.children.length, (index) {
      return AnimationController(
        vsync: this,
        duration: widget.duration,
        value: index == widget.index ? 1.0 : 0.0,
      );
    });

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      );
    }).toList();
  }

  @override
  void didUpdateWidget(covariant FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _controllers[oldWidget.index].reverse();
      _controllers[widget.index].forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.children.length, (index) {
        final animation = _animations[index];
        
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final isOffstage = index != widget.index && animation.value == 0.0;
            if (isOffstage) {
              return const SizedBox.shrink();
            }
            
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.015),
                  end: Offset.zero,
                ).animate(animation),
                child: IgnorePointer(
                  ignoring: index != widget.index,
                  child: child,
                ),
              ),
            );
          },
          child: widget.children[index],
        );
      }),
    );
  }
}

class BouncingIcon extends StatefulWidget {
  final IconData iconData;
  final bool isSelected;
  final Color color;

  const BouncingIcon({
    super.key,
    required this.iconData,
    required this.isSelected,
    required this.color,
  });

  @override
  State<BouncingIcon> createState() => _BouncingIconState();
}

class _BouncingIconState extends State<BouncingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant BouncingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Icon(widget.iconData, color: widget.color),
    );
  }
}

class HistoryFilterBottomSheet extends StatefulWidget {
  final DateTimeRange? initialRange;
  final String initialPreset;
  final ValueChanged<Map<String, dynamic>> onApply;

  const HistoryFilterBottomSheet({
    key,
    required this.initialRange,
    required this.initialPreset,
    required this.onApply,
  }) : super(key: key);

  @override
  State<HistoryFilterBottomSheet> createState() => _HistoryFilterBottomSheetState();
}

class _HistoryFilterBottomSheetState extends State<HistoryFilterBottomSheet> {
  late String _activePreset;
  late DateTime _currentMonth;
  DateTimeRange? _tempSelectedRange;

  final List<String> _monthsBn = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
  ];
  final List<String> _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _weekdaysBn = ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহস্পতি', 'শুক্র', 'শনি'];
  final List<String> _weekdaysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    _activePreset = widget.initialPreset;
    _tempSelectedRange = widget.initialRange;
    _currentMonth = DateTime.now();
    if (_tempSelectedRange != null) {
      _currentMonth = DateTime(_tempSelectedRange!.start.year, _tempSelectedRange!.start.month);
    }
  }

  void _onDayTapped(DateTime day) {
    if (_activePreset != 'custom') {
      setState(() {
        _activePreset = 'custom';
      });
    }
    setState(() {
      if (_tempSelectedRange == null) {
        _tempSelectedRange = DateTimeRange(start: day, end: day);
      } else if (_tempSelectedRange!.start == _tempSelectedRange!.end) {
        if (day.isBefore(_tempSelectedRange!.start)) {
          _tempSelectedRange = DateTimeRange(start: day, end: _tempSelectedRange!.start);
        } else {
          _tempSelectedRange = DateTimeRange(start: _tempSelectedRange!.start, end: day);
        }
      } else {
        _tempSelectedRange = DateTimeRange(start: day, end: day);
      }
    });
  }

  void _applyPreset(String preset) {
    setState(() {
      _activePreset = preset;
      final now = DateTime.now();
      if (preset == 'all') {
        _tempSelectedRange = null;
      } else if (preset == 'thisYear') {
        _tempSelectedRange = DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31),
        );
      } else if (preset == 'lastYear') {
        _tempSelectedRange = DateTimeRange(
          start: DateTime(now.year - 1, 1, 1),
          end: DateTime(now.year - 1, 12, 31),
        );
      }
    });
  }

  void _changeMonth(int increment) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + increment);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final months = isBn ? _monthsBn : _monthsEn;
    final weekdays = isBn ? _weekdaysBn : _weekdaysEn;

    final engToBnDigits = {'0':'০', '1':'১', '2':'২', '3':'৩', '4':'৪', '5':'৫', '6':'৬', '7':'৭', '8':'৮', '9':'৯'};
    String toBnNumber(String input) {
      if (!isBn) return input;
      return input.split('').map((c) => engToBnDigits[c] ?? c).join('');
    }

    final monthLabel = '${months[_currentMonth.month - 1]} ${toBnNumber(_currentMonth.year.toString())}';

    // Calendar Calculations
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final prevMonthDays = DateTime(_currentMonth.year, _currentMonth.month, 0).day;
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startOffset = firstDay.weekday % 7; // Sunday based (0 = Sunday, 6 = Saturday)

    final List<DateTime> gridDates = [];
    // Previous Month padding
    for (int i = startOffset - 1; i >= 0; i--) {
      gridDates.add(DateTime(_currentMonth.year, _currentMonth.month - 1, prevMonthDays - i));
    }
    // Current Month days
    for (int i = 1; i <= daysInMonth; i++) {
      gridDates.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }
    // Next Month padding
    final int nextDaysNeeded = 42 - gridDates.length;
    for (int i = 1; i <= nextDaysNeeded; i++) {
      gridDates.add(DateTime(_currentMonth.year, _currentMonth.month + 1, i));
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle & Title
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.date_filter_title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2923)),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preset Tabs Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetButton('all', loc.date_filter_all_time),
                const SizedBox(width: 8),
                _buildPresetButton('thisYear', loc.date_filter_this_year),
                const SizedBox(width: 8),
                _buildPresetButton('lastYear', loc.date_filter_last_year),
                const SizedBox(width: 8),
                _buildPresetButton('custom', loc.date_filter_custom),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Calendar View (only for Custom preset)
          if (_activePreset == 'custom') ...[
            // Calendar Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2923)),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black),
                      onPressed: () => _changeMonth(-1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.black),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Weekdays Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekdays.map((day) {
                return SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Days Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dayDate = gridDates[index];
                final isCurrentMonth = dayDate.month == _currentMonth.month && dayDate.year == _currentMonth.year;
                
                // Highlight calculations
                bool isSelected = false;
                bool isRangeStart = false;
                bool isRangeEnd = false;
                bool isWithinRange = false;

                if (_tempSelectedRange != null) {
                  final start = DateTime(_tempSelectedRange!.start.year, _tempSelectedRange!.start.month, _tempSelectedRange!.start.day);
                  final end = DateTime(_tempSelectedRange!.end.year, _tempSelectedRange!.end.month, _tempSelectedRange!.end.day);
                  final current = DateTime(dayDate.year, dayDate.month, dayDate.day);
                  
                  if (current == start) {
                    isRangeStart = true;
                    isSelected = true;
                  }
                  if (current == end) {
                    isRangeEnd = true;
                    isSelected = true;
                  }
                  if (current.isAfter(start) && current.isBefore(end)) {
                    isWithinRange = true;
                  }
                }

                return GestureDetector(
                  onTap: isCurrentMonth ? () => _onDayTapped(dayDate) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRangeEnd
                          ? const Color(0xFF0A462C)
                          : isRangeStart
                              ? const Color(0xFFE8F5E9)
                              : isWithinRange
                                  ? const Color(0xFFE8F5E9)
                                  : Colors.transparent,
                      border: isRangeStart
                          ? Border.all(color: const Color(0xFF0A462C), width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      toBnNumber(dayDate.day.toString()),
                      style: TextStyle(
                        fontSize: 13,
                        color: !isCurrentMonth
                            ? Colors.grey[300]
                            : isRangeEnd
                                ? Colors.white
                                : isRangeStart || isWithinRange
                                    ? const Color(0xFF0A462C)
                                    : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Selected range block indicator
          if (_tempSelectedRange != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${DateFormat('dd MMM yyyy').format(_tempSelectedRange!.start)} - ${DateFormat('dd MMM yyyy').format(_tempSelectedRange!.end)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _tempSelectedRange = null;
                        _activePreset = 'all';
                      });
                    },
                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _tempSelectedRange = null;
                      _activePreset = 'all';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0A462C),
                    side: const BorderSide(color: Color(0xFF0A462C)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(loc.date_filter_reset, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply({
                      'preset': _activePreset,
                      'range': _tempSelectedRange,
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A462C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(loc.date_filter_apply, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(String preset, String label) {
    final isSelected = _activePreset == preset;
    return GestureDetector(
      onTap: () => _applyPreset(preset),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A462C) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0A462C) : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
