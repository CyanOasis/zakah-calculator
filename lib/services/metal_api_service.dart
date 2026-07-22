import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MetalApiService {
  static const List<String> _backendBaseUrls = [
    'https://zakah-market-worker.tungsahoor958.workers.dev',
    'https://zakah-market-backup.tungsahoor958.workers.dev',
  ];
  static const Duration _refreshInterval = Duration(hours: 24);
  static const Duration _forceRefreshCooldown = Duration(minutes: 10);

  Future<Map<String, dynamic>> fetchMarketSnapshot(String currency, {bool forceRefresh = false}) async {
    final normalizedCurrency = currency.toUpperCase();

    var effectiveForceRefresh = forceRefresh;
    if (forceRefresh && !await _canForceRefresh(normalizedCurrency)) {
      effectiveForceRefresh = false;
    }

    if (!effectiveForceRefresh && await _isCacheFresh(normalizedCurrency)) {
      final cachedSnapshot = await _getCachedSnapshot(normalizedCurrency);
      return {
        ...cachedSnapshot,
        'fetch_failed': _hasBajusIssue(normalizedCurrency, cachedSnapshot),
        'requested_backend': false,
        'backend_updated': false,
        'refresh_throttled': forceRefresh && !effectiveForceRefresh,
      };
    }

    try {
      if (effectiveForceRefresh) {
        await _markForceRefresh(normalizedCurrency);
      }
      final snapshot = await _fetchFromBackend(normalizedCurrency, forceRefresh: effectiveForceRefresh);
      await _cacheSnapshot(normalizedCurrency, snapshot);
      return {
        ...snapshot,
        'fetch_failed': _hasBajusIssue(normalizedCurrency, snapshot),
        'requested_backend': true,
        'backend_updated': snapshot['cached'] != true,
        'refresh_throttled': forceRefresh && !effectiveForceRefresh,
      };
    } catch (_) {
      final snapshot = await _getCachedSnapshot(normalizedCurrency);
      return {
        ...snapshot,
        'fetch_failed': true,
        'requested_backend': effectiveForceRefresh,
        'backend_updated': false,
        'refresh_throttled': forceRefresh && !effectiveForceRefresh,
      };
    }
  }

  bool _hasBajusIssue(String currency, Map<String, dynamic> snapshot) {
    if (currency != 'BDT') return false;
    final status = (snapshot['bajus_status'] ?? '').toString().trim();
    return status == 'stale-cache' || status == 'fallback-global';
  }

  Future<bool> _isCacheFresh(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSnapshot = prefs.getString('${currency}_metal_snapshot') != null;
    if (!hasSnapshot) return false;

    final lastUpdatedRaw = prefs.getString('${currency}_last_updated');
    if (lastUpdatedRaw == null || lastUpdatedRaw.isEmpty) return false;

    final lastUpdated = DateTime.tryParse(lastUpdatedRaw);
    if (lastUpdated == null) return false;

    return DateTime.now().difference(lastUpdated) < _refreshInterval;
  }

  Future<bool> _canForceRefresh(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    final lastForceRaw = prefs.getString('${currency}_last_force_refresh');
    if (lastForceRaw == null || lastForceRaw.isEmpty) return true;

    final lastForce = DateTime.tryParse(lastForceRaw);
    if (lastForce == null) return true;

    return DateTime.now().difference(lastForce) >= _forceRefreshCooldown;
  }

  Future<void> _markForceRefresh(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${currency}_last_force_refresh', DateTime.now().toIso8601String());
  }

  Future<Map<String, dynamic>> _fetchFromBackend(String currency, {bool forceRefresh = false}) async {
    final forceParam = forceRefresh ? '&force=1' : '';
    Object? lastException;

    for (final baseUrl in _backendBaseUrls) {
      try {
        final uri = Uri.parse('$baseUrl/api/market/latest?currency=${currency.toUpperCase()}$forceParam');
        final response = await http.get(uri, headers: {
          'Accept': 'application/json',
          'User-Agent': 'ZakahCalculator/1.0',
        }).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body) as Map<String, dynamic>;
          final metals = decoded['metals'] as Map<String, dynamic>;
          final gold = metals['gold'] as Map<String, dynamic>;
          final silver = metals['silver'] as Map<String, dynamic>;
          final rawHistory = decoded['history'];
          final history = <Map<String, dynamic>>[];
          if (rawHistory is List) {
            for (final row in rawHistory) {
              if (row is! Map) continue;
              final date = row['date']?.toString() ?? '';
              final goldValue = (row['gold'] as num?)?.toDouble();
              final silverValue = (row['silver'] as num?)?.toDouble();
              if (date.isEmpty || goldValue == null || silverValue == null) continue;
              history.add({
                'date': date,
                'gold': goldValue,
                'silver': silverValue,
              });
            }
          }

          return {
            'source': decoded['source'] ?? 'Unknown',
            'updated_at': decoded['updatedAt'],
            'cached': decoded['cached'] ?? false,
            'bajus_status': decoded['bajusStatus'],
            'bajus_error': decoded['bajusError'],
            'history': history,
            'prices': {
              'gold_pure': (gold['purePerGram'] as num).toDouble(),
              'gold_24': (gold['purePerGram'] as num).toDouble(),
              'gold_22': (gold['k22PerGram'] as num).toDouble(),
              'gold_21': (gold['k21PerGram'] as num).toDouble(),
              'gold_18': (gold['k18PerGram'] as num).toDouble(),
              'gold_traditional': (gold['traditionalPerGram'] as num).toDouble(),
              'silver_pure': (silver['purePerGram'] as num).toDouble(),
            }
          };
        }
      } catch (e) {
        lastException = e;
      }
    }

    throw Exception('All backend endpoints failed: $lastException');
  }

  Future<void> _cacheSnapshot(String currency, Map<String, dynamic> snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${currency}_metal_snapshot', json.encode(snapshot));
    final backendUpdatedAt = snapshot['updated_at']?.toString();
    await prefs.setString(
      '${currency}_last_updated',
      (backendUpdatedAt == null || backendUpdatedAt.isEmpty)
          ? DateTime.now().toIso8601String()
          : backendUpdatedAt,
    );
  }

  Future<Map<String, dynamic>> _getCachedSnapshot(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${currency}_metal_snapshot');
    if (raw == null) return _getFallbackSnapshot(currency);

    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final storedUpdatedAt = prefs.getString('${currency}_last_updated');
      final existingUpdatedAt = decoded['updated_at']?.toString();
      return {
        ...decoded,
        'updated_at': (existingUpdatedAt == null || existingUpdatedAt.isEmpty)
            ? storedUpdatedAt
            : existingUpdatedAt,
        'cached': true,
      };
    } catch (_) {
      return _getFallbackSnapshot(currency);
    }
  }

  Map<String, dynamic> _getFallbackSnapshot(String currency) {
    final fallbackUpdatedAt = DateTime.now().toIso8601String();
    if (currency == 'BDT') {
      const bhoriToGrams = 11.6638;
      final gold22 = 246927.0 / bhoriToGrams;
      return {
        'source': 'BAJUS',
        'updated_at': fallbackUpdatedAt,
        'cached': true,
        'prices': {
          'gold_pure': gold22 / (22 / 24),
          'gold_24': gold22 / (22 / 24),
          'gold_22': gold22,
          'gold_21': 235671.0 / bhoriToGrams,
          'gold_18': 202020.0 / bhoriToGrams,
          'gold_traditional': 164521.0 / bhoriToGrams,
          'silver_pure': 5715.0 / bhoriToGrams,
        }
      };
    }

    const pureGoldPerGram = 65.0;
    const pureSilverPerGram = 0.80;
    return {
      'source': 'Gold API',
      'updated_at': fallbackUpdatedAt,
      'cached': true,
      'prices': {
        'gold_pure': pureGoldPerGram,
        'gold_24': pureGoldPerGram,
        'gold_22': pureGoldPerGram * (22 / 24),
        'gold_21': pureGoldPerGram * (21 / 24),
        'gold_18': pureGoldPerGram * (18 / 24),
        'gold_traditional': pureGoldPerGram * 0.60,
        'silver_pure': pureSilverPerGram,
      }
    };
  }
}
