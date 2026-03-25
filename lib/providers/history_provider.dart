import 'package:flutter/foundation.dart';
import '../models/scan_history_item.dart';
import '../repositories/history_repository.dart';

/// History Provider - Scan history state

class HistoryProvider extends ChangeNotifier {
  final HistoryRepository _historyRepository;
  
  List<ScanHistoryItem> _history = [];
  bool _isLoading = false;

  HistoryProvider(this._historyRepository);

  // Getters
  List<ScanHistoryItem> get history => _history;
  bool get isLoading => _isLoading;
  bool get hasHistory => _history.isNotEmpty;
  int get historyCount => _history.length;

  /// Load history from storage
  void loadHistory() {
    _isLoading = true;
    notifyListeners();
    
    _history = _historyRepository.getAllHistory();
    _isLoading = false;
    notifyListeners();
  }

  /// Clear all history
  Future<void> clearHistory() async {
    _isLoading = true;
    notifyListeners();
    
    await _historyRepository.clearHistory();
    _history = [];
    _isLoading = false;
    notifyListeners();
  }

  /// Delete specific item
  Future<void> deleteItem(ScanHistoryItem item) async {
    await _historyRepository.deleteItem(item);
    _history.remove(item);
    notifyListeners();
  }

  /// Refresh history
  void refresh() {
    loadHistory();
  }
}
