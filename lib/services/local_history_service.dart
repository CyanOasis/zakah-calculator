import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalHistoryService {
  static const _storageKey = 'zakat_history_entries';

  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = json.decode(raw) as List<dynamic>;
      final entries = decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      entries.sort((a, b) => (b['calculation_date'] as String)
          .compareTo(a['calculation_date'] as String));
      return entries;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCalculation({
    required String category,
    required double totalAssets,
    required double totalLiabilities,
    required double netWealth,
    required double zakatDue,
    required String currency,
    required Map<String, dynamic> details,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.insert(0, {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'category': category,
      'calculation_date': DateTime.now().toIso8601String(),
      'total_assets': totalAssets,
      'total_liabilities': totalLiabilities,
      'net_wealth': netWealth,
      'zakat_due': zakatDue,
      'currency': currency,
      'details': details,
    });
    await prefs.setString(_storageKey, json.encode(history));
  }

  Future<void> deleteItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.removeWhere((item) => item['id'] == id);
    await prefs.setString(_storageKey, json.encode(history));
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
