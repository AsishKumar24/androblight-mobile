import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/responsive.dart';
import '../providers/health_provider.dart';
import '../providers/scan_provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Splash Screen - Health check on startup

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Start health check after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      _checkHealth();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkHealth() async {
    final healthProvider = context.read<HealthProvider>();
    final scanProvider = context.read<ScanProvider>();
    
    final isOnline = await healthProvider.checkHealth();
    
    // Update scan provider with backend status
    scanProvider.setBackendStatus(isOnline);

    // Navigate based on auth state
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        final isLoggedIn = authProvider.isAuthenticated;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                isLoggedIn ? const HomeScreen() : const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: r.availableHeight,
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.spacingMD,
                        vertical: r.spacingLG,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                            width: r.adaptive(small: 90.0, medium: 110.0, large: 120.0),
                            height: r.adaptive(small: 90.0, medium: 110.0, large: 120.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.accentCyan,
                                  AppTheme.accentCyan.withAlpha(150),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentCyan.withAlpha(100),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.security,
                              size: r.adaptive(small: 45.0, medium: 55.0, large: 60.0),
                              color: AppTheme.primaryDark,
                            ),
                          ),
                          SizedBox(height: r.spacingLG),
                          // App name
                          Text(
                            'AndroBlight',
                            style: TextStyle(
                              fontSize: r.sp(32),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: r.spacingXS),
                          Text(
                            'Android Malware Detector',
                            style: TextStyle(
                              fontSize: r.sp(14),
                              color: AppTheme.accentCyan.withAlpha(200),
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: r.spacingXL),
                          // Status indicator
                          Consumer<HealthProvider>(
                            builder: (context, provider, _) {
                              return _buildStatusIndicator(provider, r);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(HealthProvider provider, Responsive r) {
    switch (provider.status) {
      case HealthStatus.initial:
      case HealthStatus.checking:
        return Column(
          children: [
            SizedBox(
              width: r.adaptive(small: 35.0, medium: 40.0),
              height: r.adaptive(small: 35.0, medium: 40.0),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
              ),
            ),
            SizedBox(height: r.spacingSM),
            Text(
              'Connecting to server...',
              style: TextStyle(
                color: AppTheme.textSecondary.withAlpha(200),
                fontSize: r.sp(13),
              ),
            ),
          ],
        );
      case HealthStatus.offline:
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(r.spacingSM),
              decoration: BoxDecoration(
                color: AppTheme.malwareRed.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: r.adaptive(small: 35.0, medium: 40.0),
                    color: AppTheme.malwareRed,
                  ),
                  SizedBox(height: r.spacingSM),
                  Text(
                    'Server Offline',
                    style: TextStyle(
                      color: AppTheme.malwareRed,
                      fontSize: r.sp(15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (provider.errorMessage != null) ...[
                    SizedBox(height: r.spacingXS),
                    Text(
                      provider.errorMessage!,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: r.sp(11),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: r.spacingMD),
            ElevatedButton.icon(
              onPressed: _checkHealth,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: AppTheme.primaryDark,
              ),
            ),
          ],
        );
      case HealthStatus.online:
        return Column(
          children: [
            Icon(
              Icons.check_circle,
              size: r.adaptive(small: 35.0, medium: 40.0),
              color: AppTheme.benignGreen,
            ),
            SizedBox(height: r.spacingSM),
            Text(
              'Connected',
              style: TextStyle(
                color: AppTheme.benignGreen,
                fontSize: r.sp(13),
              ),
            ),
          ],
        );
    }
  }
}
