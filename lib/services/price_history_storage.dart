import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PriceHistoryStorage {
  static const String _fileName = 'price_history.json';
  static const int _maxHistoryDays = 30;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<List<Map<String, dynamic>>> loadPriceHistory() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) return [];

      final decoded = json.decode(contents);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePriceHistory(List<Map<String, dynamic>> history) async {
    try {
      final file = await _localFile;
      final sortedHistory = List<Map<String, dynamic>>.from(history);
      sortedHistory.sort((a, b) =>
          (a['date'] as String).compareTo(b['date'] as String));

      if (sortedHistory.length > _maxHistoryDays) {
        sortedHistory.removeRange(0, sortedHistory.length - _maxHistoryDays);
      }

      await file.writeAsString(json.encode(sortedHistory));
    } catch (_) {
    }
  }

  Future<void> appendPriceEntry(Map<String, dynamic> entry) async {
    final history = await loadPriceHistory();
    final existingIndex = history.indexWhere(
      (e) => e['date'] == entry['date'],
    );
    if (existingIndex >= 0) {
      history[existingIndex] = entry;
    } else {
      history.add(entry);
    }
    await savePriceHistory(history);
  }

  Future<void> clearHistory() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
    }
  }
}