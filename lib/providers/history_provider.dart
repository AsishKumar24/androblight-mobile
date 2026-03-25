import 'package:flutter/foundation.dart';
import '../models/scan_history_item.dart';
import '../repositories/history_repository.dart';

/// History Provider - Scan history state with search, filter, and sort support.
/// Implements tasks 3.6: searchQuery, selectedFilter, sortOrder, filteredHistory.

enum HistoryFilter { all, malware, benign, apk, playstore }

enum HistorySortOrder { newest, oldest, highestRisk }

class HistoryProvider extends ChangeNotifier {
  final HistoryRepository _historyRepository;

  List<ScanHistoryItem> _history = [];
  bool _isLoading = false;
  bool _isSyncing = false;

  // Search / Filter / Sort state (Task 3.6)
  String _searchQuery = '';
  HistoryFilter _selectedFilter = HistoryFilter.all;
  HistorySortOrder _sortOrder = HistorySortOrder.newest;

  // Sync feedback
  String? _syncMessage;
  bool? _syncSuccess;

  HistoryProvider(this._historyRepository);

  // ──── Getters ────
  List<ScanHistoryItem> get history => _history;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get hasHistory => _history.isNotEmpty;
  int get historyCount => _history.length;

  String get searchQuery => _searchQuery;
  HistoryFilter get selectedFilter => _selectedFilter;
  HistorySortOrder get sortOrder => _sortOrder;

  String? get syncMessage => _syncMessage;
  bool? get syncSuccess => _syncSuccess;

  /// Filtered + sorted history based on current search/filter/sort state
  List<ScanHistoryItem> get filteredHistory {
    List<ScanHistoryItem> result = List.from(_history);

    // 1. Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((item) {
        return item.displayName.toLowerCase().contains(query) ||
            item.identifier.toLowerCase().contains(query) ||
            (item.fileName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // 2. Category filter
    switch (_selectedFilter) {
      case HistoryFilter.malware:
        result = result.where((item) => item.isMalware).toList();
        break;
      case HistoryFilter.benign:
        result = result.where((item) => item.isBenign).toList();
        break;
      case HistoryFilter.apk:
        result = result.where((item) => item.isApkScan).toList();
        break;
      case HistoryFilter.playstore:
        result = result.where((item) => item.isPlayStoreScan).toList();
        break;
      case HistoryFilter.all:
        break;
    }

    // 3. Sort
    switch (_sortOrder) {
      case HistorySortOrder.newest:
        result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case HistorySortOrder.oldest:
        result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case HistorySortOrder.highestRisk:
        // Malware first, then sort by confidence descending
        result.sort((a, b) {
          if (a.isMalware && !b.isMalware) return -1;
          if (!a.isMalware && b.isMalware) return 1;
          return b.confidence.compareTo(a.confidence);
        });
        break;
    }

    return result;
  }

  // ──── Setters ────

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(HistoryFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSortOrder(HistorySortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedFilter = HistoryFilter.all;
    _sortOrder = HistorySortOrder.newest;
    notifyListeners();
  }

  void clearSyncMessage() {
    _syncMessage = null;
    _syncSuccess = null;
    notifyListeners();
  }

  // ──── Actions ────

  /// Load history from local storage
  void loadHistory() {
    _isLoading = true;
    notifyListeners();

    _history = _historyRepository.getAllHistory();
    _isLoading = false;
    notifyListeners();
  }

  /// Sync history with the cloud
  Future<void> syncWithCloud() async {
    _isSyncing = true;
    _syncMessage = null;
    _syncSuccess = null;
    notifyListeners();

    final result = await _historyRepository.syncWithCloud();

    if (result.hasError) {
      _syncMessage = result.error;
      _syncSuccess = false;
    } else if (result.hasChanges) {
      _syncMessage =
          'Synced: ${result.pushed} pushed, ${result.pulled} pulled';
      _syncSuccess = true;
      // Reload local history to include newly pulled records
      _history = _historyRepository.getAllHistory();
    } else {
      _syncMessage = 'Already up to date';
      _syncSuccess = true;
    }

    _isSyncing = false;
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
