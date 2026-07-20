import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/metal_api_service.dart';
import '../services/price_history_storage.dart';

class Country {
  final String name;
  final String currency;
  final String flag;
  final String languageCode;
  final String weightUnit; // 'g' or 'bhori'
  final double goldPremium;
  final double silverPremium;
  final double? manualSilverNisab;

  Country({
    required this.name,
    required this.currency,
    required this.flag,
    required this.languageCode,
    this.weightUnit = 'g',
    this.goldPremium = 1.0,
    this.silverPremium = 1.0,
    this.manualSilverNisab,
  });
}

class MetalItem {
  final String id;
  final double weight;
  final String unit; // 'gram', 'bhori', 'ana', 'ounce'
  final int? purity; // Nullable for silver, e.g., 24, 22, 21, 18, 0 (for traditional)

  MetalItem({
    required this.id,
    required this.weight,
    required this.unit,
    this.purity,
  });
}

class ZakatProvider with ChangeNotifier {
  final MetalApiService _apiService = MetalApiService();
  final PriceHistoryStorage _priceHistoryStorage = PriceHistoryStorage();
  static const String _prefCurrencyKey = 'selected_currency';
  static const String _prefLanguageKey = 'selected_language';
  static const int _marketTrendDays = 30;

  // New multi-item metal entry lists
  List<MetalItem> goldItems = [];
  List<MetalItem> silverItems = [];


  List<Country> countries = [
    Country(
      name: 'Bangladesh',
      currency: 'BDT',
      flag: '🇧🇩',
      languageCode: 'bn',
      weightUnit: 'bhori',
    ),
    Country(
      name: 'Turkey',
      currency: 'TRY',
      flag: '🇹🇷',
      languageCode: 'tr',
    ),
    Country(name: 'Pakistan', currency: 'PKR', flag: '🇵🇰', languageCode: 'en'),
    Country(name: 'India', currency: 'INR', flag: '🇮🇳', languageCode: 'en'),
    Country(name: 'USA', currency: 'USD', flag: '🇺🇸', languageCode: 'en'),
    Country(name: 'UAE', currency: 'AED', flag: '🇦🇪', languageCode: 'en'),
    Country(name: 'Saudi Arabia', currency: 'SAR', flag: '🇸🇦', languageCode: 'en'),
  ];

  late Country _selectedCountry;
  String _selectedLanguageCode = 'bn';
  double _goldPricePerGram = 0.0;
  double _silverPricePerGram = 0.0;
  double _gold22PricePerGram = 0.0;
  double _gold21PricePerGram = 0.0;
  double _gold18PricePerGram = 0.0;
  double _goldTraditionalPricePerGram = 0.0;
  double? _calculationGoldPriceOverridePerGram;
  double? _calculationSilverPriceOverridePerGram;
  bool _isLoading = false;
  String _marketSource = '';
  String? _marketUpdatedAt;
  bool _marketCached = false;
  bool _marketFetchFailed = false;
  List<double> _goldTrendHistory = const [];
  List<double> _silverTrendHistory = const [];
  double _goldChangePercent = 0.0;
  double _silverChangePercent = 0.0;
  int _fetchRequestId = 0;
  Timer? _heartbeatTimer;
  DateTime? _lastManualRefreshAt;

  static const Duration _manualRefreshCooldown = Duration(minutes: 10);
  final double _bhoriToGrams = 11.6638;

  // Securities State
  double cash = 0.0;
  double bank = 0.0;
  double goldWeight = 0.0;
  int goldCarat = 22; // Default to 22K
  double silverWeight = 0.0;
  double investments = 0.0;
  double businessAssets = 0.0;
  double receivables = 0.0;
  double otherAssets = 0.0;
  double debts = 0.0;
  bool hawlCompleted = false;
  String nisabMethod = 'silver';

  // Animals State
  int sheepCount = 0;
  int cowCount = 0;
  int camelCount = 0;

  void updateAnimalCounts({int? sheep, int? cow, int? camel}) {
    if (sheep != null) sheepCount = sheep;
    if (cow != null) cowCount = cow;
    if (camel != null) camelCount = camel;
    notifyListeners();
  }

  // Ushur State
  double cropYield = 0.0;
  bool isNaturallyIrrigated = true;

  void updateUshur({double? yieldAmount, bool? isNatural}) {
    if (yieldAmount != null) cropYield = yieldAmount;
    if (isNatural != null) isNaturallyIrrigated = isNatural;
    notifyListeners();
  }

  ZakatProvider() {
    _selectedCountry = countries[0];
    _restoreSelections();
    _heartbeatTimer = Timer.periodic(const Duration(hours: 24), (_) {
      fetchPrices();
    });
  }

  Country get selectedCountry => _selectedCountry;
  String get selectedLanguageCode => _selectedLanguageCode;
  List<String> get supportedLanguageCodes => ['bn', 'tr', 'en'];
  bool get isLoading => _isLoading;
  String get marketSource => _marketSource;
  String get marketUpdatedLabel => _marketUpdatedAt == null || _marketUpdatedAt!.isEmpty ? '--' : _marketUpdatedAt!;
  bool get marketIsCached => _marketCached;
  bool get marketFetchFailed => _marketFetchFailed;
  List<double> get goldTrendHistory => _goldTrendHistory;
  List<double> get silverTrendHistory => _silverTrendHistory;
  double get goldChangePercent => _goldChangePercent;
  double get silverChangePercent => _silverChangePercent;

  bool get usesBhoriUnit => _selectedCountry.weightUnit == 'bhori';

  String get unitNameLabel {
    if (usesBhoriUnit) {
      if (_selectedLanguageCode == 'bn') return 'ভরি';
      return 'bhori';
    }
    if (_selectedLanguageCode == 'bn') return 'গ্রাম';
    return 'g';
  }

  String get perUnitLabel {
    if (usesBhoriUnit) {
      if (_selectedLanguageCode == 'bn') return 'প্রতি ভরি';
      if (_selectedLanguageCode == 'tr') return 'bhori başına';
      return 'per bhori';
    }
    if (_selectedLanguageCode == 'bn') return 'প্রতি গ্রাম';
    if (_selectedLanguageCode == 'tr') return 'gram başına';
    return 'per gram';
  }

  double get pureGoldPriceDisplay => _selectedCountry.weightUnit == 'bhori'
      ? _goldPricePerGram * _bhoriToGrams
      : _goldPricePerGram;

  double get goldPriceDisplay => _selectedCountry.weightUnit == 'bhori' 
      ? goldPricePerGramForCarat * _bhoriToGrams 
      : goldPricePerGramForCarat;

  double get silverPriceDisplay => _selectedCountry.weightUnit == 'bhori' 
      ? _silverPricePerGram * _bhoriToGrams 
      : _silverPricePerGram;

  double get effectiveGoldPricePerGram => _calculationGoldPriceOverridePerGram ?? _goldPricePerGram;

  double get effectiveSilverPricePerGram => _calculationSilverPriceOverridePerGram ?? _silverPricePerGram;

  double goldPriceForCarat(int carat) {
    final baseGold = effectiveGoldPricePerGram;
    switch (carat) {
      case 24:
        return baseGold;
      case 22:
        return _calculationGoldPriceOverridePerGram != null
            ? baseGold * (22.0 / 24.0)
            : (_gold22PricePerGram > 0 ? _gold22PricePerGram : baseGold * (22.0 / 24.0));
      case 21:
        return _calculationGoldPriceOverridePerGram != null
            ? baseGold * (21.0 / 24.0)
            : (_gold21PricePerGram > 0 ? _gold21PricePerGram : baseGold * (21.0 / 24.0));
      case 18:
        return _calculationGoldPriceOverridePerGram != null
            ? baseGold * (18.0 / 24.0)
            : (_gold18PricePerGram > 0 ? _gold18PricePerGram : baseGold * (18.0 / 24.0));
      case 0:
        return _calculationGoldPriceOverridePerGram != null
            ? baseGold * 0.60
            : (_goldTraditionalPricePerGram > 0 ? _goldTraditionalPricePerGram : baseGold * 0.60);
      default:
        return _calculationGoldPriceOverridePerGram != null
            ? baseGold * (22.0 / 24.0)
            : (_gold22PricePerGram > 0 ? _gold22PricePerGram : baseGold * (22.0 / 24.0));
    }
  }

  double get goldPricePerGramForCarat => goldPriceForCarat(goldCarat);


  String languageLabel(String code) => code.toUpperCase();

  Future<void> _restoreSelections() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString(_prefCurrencyKey);
    final savedLanguage = prefs.getString(_prefLanguageKey);

    if (savedCurrency != null) {
      for (final country in countries) {
        if (country.currency == savedCurrency) {
          _selectedCountry = country;
          break;
        }
      }
    }

    if (savedLanguage != null && ['bn', 'tr', 'en'].contains(savedLanguage)) {
      _selectedLanguageCode = savedLanguage;
    }

    await _loadPersistedHistory();

    notifyListeners();
    await fetchPrices();
  }

  Future<void> _loadPersistedHistory() async {
    final history = await _priceHistoryStorage.loadPriceHistory();
    if (history.isNotEmpty) {
      _applyTrendHistory(history);
    }
  }

  Future<void> _saveSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefCurrencyKey, _selectedCountry.currency);
  }

  Future<void> _saveSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageKey, _selectedLanguageCode);
  }

  void setLanguage(String languageCode) {
    if (!['bn', 'tr', 'en'].contains(languageCode)) return;
    if (_selectedLanguageCode == languageCode) return;
    _selectedLanguageCode = languageCode;
    notifyListeners();
    _saveSelectedLanguage();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  void setCountry(Country country) {
    if (_selectedCountry.currency == country.currency) return;
    _selectedCountry = country;
    _marketSource = '';
    _marketUpdatedAt = null;
    _marketCached = false;
    _marketFetchFailed = false;
    _goldTrendHistory = const [];
    _silverTrendHistory = const [];
    _goldChangePercent = 0.0;
    _silverChangePercent = 0.0;
    _goldPricePerGram = 0.0;
    _gold22PricePerGram = 0.0;
    _gold21PricePerGram = 0.0;
    _gold18PricePerGram = 0.0;
    _goldTraditionalPricePerGram = 0.0;
    _silverPricePerGram = 0.0;
    _calculationGoldPriceOverridePerGram = null;
    _calculationSilverPriceOverridePerGram = null;
    notifyListeners();
    _saveSelectedCurrency();
    fetchPrices();
  }

  Future<void> manualRefreshPrices() async {
    final now = DateTime.now();
    if (_lastManualRefreshAt != null && now.difference(_lastManualRefreshAt!) < _manualRefreshCooldown) {
      await fetchPrices();
      return;
    }

    _lastManualRefreshAt = now;
    await fetchPrices(forceRefresh: true);
  }

  Future<void> fetchPrices({bool forceRefresh = false}) async {
    final requestId = ++_fetchRequestId;
    final currency = _selectedCountry.currency;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _apiService.fetchMarketSnapshot(currency, forceRefresh: forceRefresh);
      if (requestId != _fetchRequestId || currency != _selectedCountry.currency) return;

      final prices = Map<String, dynamic>.from(snapshot['prices'] as Map);
      _marketSource = (snapshot['source'] ?? '').toString();
      final incomingUpdatedAt = snapshot['updated_at']?.toString();
      final backendUpdated = snapshot['backend_updated'] == true;
      final fetchFailed = snapshot['fetch_failed'] == true;
      if (!fetchFailed && (backendUpdated || _marketUpdatedAt == null || _marketUpdatedAt!.isEmpty)) {
        _marketUpdatedAt = incomingUpdatedAt;
      }
      _marketCached = snapshot['cached'] == true;
      _marketFetchFailed = fetchFailed;
      _goldPricePerGram = (prices['gold_pure'] as num?)?.toDouble() ?? 0.0;
      _gold22PricePerGram = (prices['gold_22'] as num?)?.toDouble() ?? _goldPricePerGram * (22.0 / 24.0);
      _gold21PricePerGram = (prices['gold_21'] as num?)?.toDouble() ?? _goldPricePerGram * (21.0 / 24.0);
      _gold18PricePerGram = (prices['gold_18'] as num?)?.toDouble() ?? _goldPricePerGram * (18.0 / 24.0);
      _goldTraditionalPricePerGram = (prices['gold_traditional'] as num?)?.toDouble() ?? _goldPricePerGram * 0.60;
      _silverPricePerGram = (prices['silver_pure'] as num?)?.toDouble() ?? 0.0;
      _applyBackendTrendHistory(snapshot['history']);
    } catch (e) {
      if (requestId == _fetchRequestId) {
        _marketFetchFailed = true;
        debugPrint('Error fetching prices: $e');
      }
    } finally {
      if (requestId == _fetchRequestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _applyBackendTrendHistory(dynamic rawHistory) {
    final normalized = <Map<String, dynamic>>[];
    if (rawHistory is List) {
      for (final row in rawHistory) {
        if (row is! Map) continue;
        final date = row['date']?.toString() ?? '';
        final gold = (row['gold'] as num?)?.toDouble();
        final silver = (row['silver'] as num?)?.toDouble();
        if (date.isEmpty || gold == null || silver == null || gold <= 0 || silver <= 0) {
          continue;
        }
        normalized.add({'date': date, 'gold': gold, 'silver': silver});
      }
    }

    normalized.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    if (normalized.length > _marketTrendDays) {
      normalized.removeRange(0, normalized.length - _marketTrendDays);
    }

    if (normalized.isEmpty && _goldPricePerGram > 0 && _silverPricePerGram > 0) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      normalized.add({
        'date': today,
        'gold': _goldPricePerGram,
        'silver': _silverPricePerGram,
      });
    }

    _applyTrendHistory(normalized);
    _persistTrendHistory(normalized);
  }

  void _persistTrendHistory(List<Map<String, dynamic>> history) {
    _priceHistoryStorage.savePriceHistory(history);
  }

  void _applyTrendHistory(List<Map<String, dynamic>> history) {
    _goldTrendHistory = history.map((row) => (row['gold'] as num).toDouble()).toList(growable: false);
    _silverTrendHistory = history.map((row) => (row['silver'] as num).toDouble()).toList(growable: false);
    _goldChangePercent = _calculateChangePercent(_goldTrendHistory);
    _silverChangePercent = _calculateChangePercent(_silverTrendHistory);
  }

  double _calculateChangePercent(List<double> values) {
    if (values.length < 2) return 0.0;
    final previous = values[values.length - 2];
    final current = values.last;
    if (previous <= 0) return 0.0;
    return ((current - previous) / previous) * 100.0;
  }

  double get goldNisabThreshold => 87.5 * effectiveGoldPricePerGram;

  double get silverNisabThreshold => 612.36 * effectiveSilverPricePerGram;

  double get selectedNisabThreshold => nisabMethod == 'gold' ? goldNisabThreshold : silverNisabThreshold;

  double get _weightMultiplier => _selectedCountry.weightUnit == 'bhori' ? _bhoriToGrams : 1.0;

  double calculateMetalItemValue(MetalItem item, bool isGold) {
    double multiplier = 1.0;
    if (item.unit == 'bhori') multiplier = _bhoriToGrams;
    if (item.unit == 'ana') multiplier = 0.729;
    if (item.unit == 'ounce') multiplier = 31.1034768;

    double weightInGrams = item.weight * multiplier;

    if (isGold) {
      return weightInGrams * goldPriceForCarat(item.purity ?? 22);
    } else {
      final baseSilver = effectiveSilverPricePerGram;
      switch (item.purity ?? 24) {
        case 24:
          return weightInGrams * baseSilver;
        case 22:
          return weightInGrams * baseSilver * 0.925;
        case 21:
          return weightInGrams * baseSilver * 0.900;
        case 19:
          return weightInGrams * baseSilver * 0.800;
        default:
          return weightInGrams * baseSilver;
      }
    }
  }

  double get computedGoldItemsValue {
    if (goldItems.isEmpty) return goldWeight * _weightMultiplier * goldPricePerGramForCarat;
    return goldItems.fold(0.0, (sum, item) => sum + calculateMetalItemValue(item, true));
  }

  double get computedSilverItemsValue {
    if (silverItems.isEmpty) return silverWeight * _weightMultiplier * _silverPricePerGram;
    return silverItems.fold(0.0, (sum, item) => sum + calculateMetalItemValue(item, false));
  }

  void addGoldItem(MetalItem item) {
    goldItems.add(item);
    notifyListeners();
  }

  void removeGoldItem(String id) {
    goldItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void addSilverItem(MetalItem item) {
    silverItems.add(item);
    notifyListeners();
  }

  void removeSilverItem(String id) {
    silverItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Securities Calculation
  double get totalAssets =>
      cash +
      bank +
      computedGoldItemsValue +
      computedSilverItemsValue +
      investments +
      businessAssets +
      receivables +
      otherAssets;
  double get netWealth => math.max(totalAssets - debts, 0.0);

  bool get isZakatEligible => netWealth >= selectedNisabThreshold;

  bool get isZakatDue => isZakatEligible && hawlCompleted;

  double get zakatDue => isZakatDue ? netWealth * 0.025 : 0.0;

  // Livestock Zakat Logic
  String get animalZakatResult {
    List<String> results = [];
    
    // Sheep/Goats
    if (sheepCount >= 40) {
      if (sheepCount <= 120) results.add('1 sheep');
      else if (sheepCount <= 200) results.add('2 sheep');
      else if (sheepCount <= 399) results.add('3 sheep');
      else {
        int count = 4 + ((sheepCount - 400) ~/ 100);
        results.add('$count sheep');
      }
    }

    // Cows
    if (cowCount >= 30) {
      if (cowCount <= 39) results.add('1-year-old calf');
      else if (cowCount <= 59) results.add('2-year-old calf');
      else results.add('Two 1-year-old calves');
    }

    // Camels (Simple version)
    if (camelCount >= 5) {
      if (camelCount < 25) results.add('${camelCount ~/ 5} sheep');
      else results.add('1 young she-camel');
    }

    return results.isEmpty ? 'No Zakat currently due' : results.join(', ');
  }

  // Ushur Calculation
  double get ushurDue => cropYield * (isNaturallyIrrigated ? 0.10 : 0.05);

  void setCalculationPriceOverrides({double? goldPerGram, double? silverPerGram, bool notify = true}) {
    final normalizedGold = (goldPerGram != null && goldPerGram > 0) ? goldPerGram : null;
    final normalizedSilver = (silverPerGram != null && silverPerGram > 0) ? silverPerGram : null;

    final hasChanged = _calculationGoldPriceOverridePerGram != normalizedGold ||
        _calculationSilverPriceOverridePerGram != normalizedSilver;

    _calculationGoldPriceOverridePerGram = normalizedGold;
    _calculationSilverPriceOverridePerGram = normalizedSilver;

    if (hasChanged && notify) {
      notifyListeners();
    }
  }

  void clearCalculationPriceOverrides({bool notify = true}) {
    setCalculationPriceOverrides(goldPerGram: null, silverPerGram: null, notify: notify);
  }

  void resetInputs() {
    cash = 0.0; bank = 0.0; goldWeight = 0.0; silverWeight = 0.0;
    investments = 0.0; businessAssets = 0.0; receivables = 0.0;
    otherAssets = 0.0; debts = 0.0;
    goldItems.clear();
    silverItems.clear();
    sheepCount = 0; cowCount = 0; camelCount = 0;
    cropYield = 0.0;
    hawlCompleted = false;
    nisabMethod = 'silver';
    _calculationGoldPriceOverridePerGram = null;
    _calculationSilverPriceOverridePerGram = null;
    notifyListeners();
  }

  void setHawlCompleted(bool value) {
    hawlCompleted = value;
    notifyListeners();
  }

  void setNisabMethod(String value) {
    nisabMethod = value;
    notifyListeners();
  }
}
