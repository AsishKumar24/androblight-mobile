import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/responsive.dart';
import '../providers/scan_provider.dart';
import 'result_screen.dart';

/// Play Store Scan Screen

class ScanPlaystoreScreen extends StatefulWidget {
  const ScanPlaystoreScreen({super.key});

  @override
  State<ScanPlaystoreScreen> createState() => _ScanPlaystoreScreenState();
}

class _ScanPlaystoreScreenState extends State<ScanPlaystoreScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scanApp() async {
    final input = _controller.text.trim();
    
    if (input.isEmpty) {
      setState(() => _errorText = 'Please enter a URL or package name');
      return;
    }

    final scanProvider = context.read<ScanProvider>();
    
    if (!scanProvider.isValidPlayStoreInput(input)) {
      setState(() => _errorText = 'Invalid Play Store URL or package name');
      return;
    }

    setState(() => _errorText = null);
    await scanProvider.scanPlayStoreApp(input);

    if (mounted) {
      if (scanProvider.hasResult) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              result: scanProvider.result!,
              scanType: 'Play Store',
              identifier: input,
            ),
          ),
        );
      } else if (scanProvider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(scanProvider.errorMessage ?? 'An error occurred'),
            backgroundColor: AppTheme.malwareRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Play Store App'),
        actions: [
          Consumer<ScanProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: provider.isBackendOnline ? AppTheme.benignGreen : AppTheme.malwareRed,
                      boxShadow: [
                        BoxShadow(
                          color: (provider.isBackendOnline ? AppTheme.benignGreen : AppTheme.malwareRed).withAlpha(100),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ScanProvider>(
        builder: (context, scanProvider, _) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: r.availableHeight - kToolbarHeight,
              ),
              child: Padding(
                padding: r.screenPadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Icon header
                      Center(
                        child: Container(
                          width: r.adaptive(small: 70.0, medium: 80.0, large: 90.0),
                          height: r.adaptive(small: 70.0, medium: 80.0, large: 90.0),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.store,
                            size: r.adaptive(small: 35.0, medium: 40.0, large: 45.0),
                            color: AppTheme.accentBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: r.spacingMD),
                      // Instructions
                      Text(
                        'Enter Play Store URL or Package Name',
                        style: TextStyle(
                          fontSize: r.sp(16),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: r.spacingXS),
                      Text(
                        'We\'ll analyze the app for potential malware',
                        style: TextStyle(
                          fontSize: r.sp(13),
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: r.spacingLG),
                      // Input field
                      TextFormField(
                        controller: _controller,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: r.sp(14),
                        ),
                        decoration: InputDecoration(
                          hintText: 'play.google.com/... or com.example.app',
                          prefixIcon: Icon(
                            Icons.link,
                            color: AppTheme.accentBlue,
                            size: r.adaptive(small: 20.0, medium: 22.0),
                          ),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() => _errorText = null);
                                  },
                                )
                              : null,
                          errorText: _errorText,
                        ),
                        onChanged: (_) => setState(() => _errorText = null),
                      ),
                      SizedBox(height: r.spacingMD),
                      // Examples
                      Container(
                        padding: EdgeInsets.all(r.spacingSM),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Examples:',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: r.sp(11),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: r.spacingXS),
                            _exampleItem(
                              'play.google.com/store/apps/details?id=com.whatsapp',
                              r,
                            ),
                            SizedBox(height: r.spacingXS),
                            _exampleItem('com.instagram.android', r),
                          ],
                        ),
                      ),
                      SizedBox(height: r.spacingLG),
                      // Scan button
                      ElevatedButton(
                        onPressed: scanProvider.isScanning ? null : _scanApp,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: r.spacingSM + 4),
                          backgroundColor: AppTheme.accentBlue,
                          disabledBackgroundColor: AppTheme.textMuted.withAlpha(75),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (scanProvider.isScanning) ...[
                              SizedBox(
                                width: r.adaptive(small: 18.0, medium: 20.0),
                                height: r.adaptive(small: 18.0, medium: 20.0),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryDark,
                                  ),
                                ),
                              ),
                              SizedBox(width: r.spacingSM),
                              Text(
                                scanProvider.isUsingDemoMode ? 'Demo Analysis...' : 'Server Analysis...',
                                style: TextStyle(fontSize: r.sp(15)),
                              ),
                            ] else ...[
                              Icon(
                                Icons.search,
                                size: r.adaptive(small: 20.0, medium: 22.0),
                              ),
                              SizedBox(width: r.spacingSM),
                              Text(
                                'Scan App',
                                style: TextStyle(fontSize: r.sp(15)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _exampleItem(String text, Responsive r) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        setState(() => _errorText = null);
      },
      child: Row(
        children: [
          Icon(
            Icons.touch_app,
            size: r.adaptive(small: 14.0, medium: 16.0),
            color: AppTheme.accentBlue,
          ),
          SizedBox(width: r.spacingXS),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: r.sp(11),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
