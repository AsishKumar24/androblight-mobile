import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'repositories/scan_repository.dart';
import 'repositories/history_repository.dart';
import 'providers/health_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/history_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final storageService = StorageService();
  await storageService.init();
  
  final apiService = ApiService();
  
  // Create repositories
  final scanRepository = ScanRepository(apiService);
  final historyRepository = HistoryRepository(storageService);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HealthProvider(scanRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ScanProvider(scanRepository, historyRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(historyRepository),
        ),
      ],
      child: const AndroBlight(),
    ),
  );
}

class AndroBlight extends StatelessWidget {
  const AndroBlight({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AndroBlight',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}