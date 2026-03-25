import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/responsive.dart';
import 'scan_apk_screen.dart';
import 'scan_playstore_screen.dart';
import 'history_screen.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';

/// Home Screen - Main navigation hub

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryLight,
              AppTheme.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: r.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: r.adaptive(small: 42.0, medium: 48.0, large: 50.0),
                            height: r.adaptive(small: 42.0, medium: 48.0, large: 50.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.accentCyan,
                                  AppTheme.accentCyan.withAlpha(180),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.security,
                              color: AppTheme.primaryDark,
                              size: r.adaptive(small: 22.0, medium: 26.0, large: 28.0),
                            ),
                          ),
                          SizedBox(width: r.spacingSM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AndroBlight',
                                  style: TextStyle(
                                    fontSize: r.sp(20),
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Consumer<ScanProvider>(
                                      builder: (context, provider, _) {
                                        final isOnline = provider.isBackendOnline;
                                        return Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isOnline ? AppTheme.benignGreen : AppTheme.malwareRed,
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isOnline ? AppTheme.benignGreen : AppTheme.malwareRed).withAlpha(100),
                                                blurRadius: 4,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Malware Detection',
                                      style: TextStyle(
                                        fontSize: r.sp(12),
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // History button
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const HistoryScreen(),
                                ),
                              );
                            },
                            icon: Container(
                              padding: EdgeInsets.all(r.spacingSM),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.history,
                                color: AppTheme.accentCyan,
                                size: r.adaptive(small: 20.0, medium: 22.0, large: 24.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: r.spacingLG),
                      // Title
                      Text(
                        'What would you like\nto scan today?',
                        style: TextStyle(
                          fontSize: r.sp(24),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: r.spacingXS),
                      Text(
                        'Choose a scan method to analyze for malware',
                        style: TextStyle(
                          fontSize: r.sp(13),
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: r.spacingLG),
                      // Action cards
                      _ActionCard(
                        icon: Icons.android,
                        title: 'Scan APK File',
                        description: 'Upload and analyze a local APK file',
                        gradient: [
                          AppTheme.accentCyan.withAlpha(50),
                          AppTheme.accentCyan.withAlpha(12),
                        ],
                        iconColor: AppTheme.accentCyan,
                        responsive: r,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ScanApkScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: r.spacingMD),
                      // Scan Play Store card
                      _ActionCard(
                        icon: Icons.store,
                        title: 'Scan Play Store App',
                        description: 'Analyze using Play Store URL or package name',
                        gradient: [
                          AppTheme.accentBlue.withAlpha(50),
                          AppTheme.accentBlue.withAlpha(12),
                        ],
                        iconColor: AppTheme.accentBlue,
                        responsive: r,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ScanPlaystoreScreen(),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      // Footer
                      Center(
                        child: Text(
                          'Powered by AndroBlight Group - 47',
                          style: TextStyle(
                            fontSize: r.sp(11),
                            color: AppTheme.textMuted.withAlpha(150),
                          ),
                        ),
                      ),
                      SizedBox(height: r.spacingSM),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final Color iconColor;
  final Responsive responsive;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.iconColor,
    required this.responsive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(r.spacingMD),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: iconColor.withAlpha(75),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: r.adaptive(small: 55.0, medium: 65.0, large: 70.0),
                height: r.adaptive(small: 55.0, medium: 65.0, large: 70.0),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: r.adaptive(small: 28.0, medium: 34.0, large: 36.0),
                  color: iconColor,
                ),
              ),
              SizedBox(width: r.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: r.sp(17),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: r.spacingXS),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: r.sp(12),
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: iconColor.withAlpha(200),
                size: r.adaptive(small: 16.0, medium: 18.0, large: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
