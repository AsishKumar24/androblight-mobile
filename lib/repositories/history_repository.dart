import '../models/scan_history_item.dart';
import '../models/scan_result.dart';
import '../services/storage_service.dart';

/// History Repository - Abstraction layer for scan history

class HistoryRepository {
  final StorageService _storageService;

  HistoryRepository(this._storageService);

  /// Get all scan history
  List<ScanHistoryItem> getAllHistory() {
    return _storageService.getAllHistory();
  }

  /// Add APK scan result to history
  Future<void> addApkScanToHistory({
    required String fileName,
    required int fileSize,
    required ScanResult result,
  }) async {
    final item = ScanHistoryItem(
      scanType: 'apk',
      identifier: fileName,
      timestamp: DateTime.now(),
      label: result.label,
      confidence: result.confidence,
      fileName: fileName,
      fileSize: fileSize,
    );
    await _storageService.addToHistory(item);
  }

  /// Add Play Store scan result to history
  Future<void> addPlayStoreScanToHistory({
    required String identifier,
    required ScanResult result,
  }) async {
    final item = ScanHistoryItem(
      scanType: 'playstore',
      identifier: identifier,
      timestamp: DateTime.now(),
      label: result.label,
      confidence: result.confidence,
    );
    await _storageService.addToHistory(item);
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await _storageService.clearHistory();
  }

  /// Delete specific item
  Future<void> deleteItem(ScanHistoryItem item) async {
    await _storageService.deleteHistoryItem(item);
  }

  /// Get history count
  int get historyCount => _storageService.historyCount;
}
