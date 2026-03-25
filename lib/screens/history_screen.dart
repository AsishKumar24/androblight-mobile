import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/responsive.dart';
import '../providers/history_provider.dart';
import '../widgets/scan_card.dart';

/// History Screen - Past scans list

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load history when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all scan history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.malwareRed,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<HistoryProvider>().clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, provider, _) {
              if (provider.history.isEmpty) return const SizedBox();
              return IconButton(
                onPressed: _clearHistory,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear History',
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.history.isEmpty) {
            return Center(
              child: Padding(
                padding: r.screenPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: r.adaptive(small: 70.0, medium: 80.0),
                      height: r.adaptive(small: 70.0, medium: 80.0),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history,
                        size: r.adaptive(small: 35.0, medium: 40.0),
                        color: AppTheme.textMuted,
                      ),
                    ),
                    SizedBox(height: r.spacingMD),
                    Text(
                      'No scan history',
                      style: TextStyle(
                        fontSize: r.sp(16),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: r.spacingXS),
                    Text(
                      'Your scanned files will appear here',
                      style: TextStyle(
                        fontSize: r.sp(13),
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: r.screenPadding,
            itemCount: provider.history.length,
            separatorBuilder: (context, index) => SizedBox(height: r.spacingSM),
            itemBuilder: (context, index) {
              final item = provider.history[index];
              return ScanCard(
                item: item,
                responsive: r,
                onDelete: () async {
                  await provider.deleteItem(item);
                },
              );
            },
          );
        },
      ),
    );
  }
}
