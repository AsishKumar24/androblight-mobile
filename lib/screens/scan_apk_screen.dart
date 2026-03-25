import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../core/theme.dart';
import '../core/responsive.dart';
import '../providers/scan_provider.dart';
import '../widgets/loading_overlay.dart';
import 'result_screen.dart';

/// Scan APK Screen - Handles file selection and scanning
class ScanApkScreen extends StatefulWidget {
  const ScanApkScreen({super.key});

  @override
  State<ScanApkScreen> createState() => _ScanApkScreenState();
}

class _ScanApkScreenState extends State<ScanApkScreen> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['apk'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _handleScan({bool isSample = false}) async {
    if (!isSample && _selectedFile == null) return;

    final provider = context.read<ScanProvider>();
    
    if (isSample) {
      // Create a dummy file object for the provider
      await provider.scanApkFile(File('sample_malware.apk'), isSample: true);
    } else {
      await provider.scanApkFile(_selectedFile!);
    }

    if (mounted && provider.hasResult) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            result: provider.result!,
            scanType: 'APK Scan',
            identifier: provider.currentFileName ?? 'Selected File',
          ),
        ),
      );
    } else if (mounted && provider.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Scan failed'),
          backgroundColor: AppTheme.malwareRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final provider = context.watch<ScanProvider>();

    return LoadingOverlay(
      isLoading: provider.isScanning,
      message: provider.scanningMessage,
      progress: provider.uploadProgress,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan APK File'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryLight, AppTheme.primaryDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: r.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    Icons.android_rounded,
                    size: r.adaptive(small: 80, medium: 100),
                    color: AppTheme.accentCyan,
                  ),
                  const SizedBox(height: 40),
                  
                  // Selection area
                  GestureDetector(
                    onTap: provider.isScanning ? null : _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedFile != null 
                              ? AppTheme.accentCyan 
                              : AppTheme.textMuted.withAlpha(50),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFile != null ? Icons.file_present : Icons.cloud_upload_outlined,
                            size: 48,
                            color: _selectedFile != null ? AppTheme.accentCyan : AppTheme.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFile != null 
                                ? _selectedFile!.path.split(Platform.pathSeparator).last
                                : 'Select an APK file to scan',
                            style: TextStyle(
                              color: _selectedFile != null ? AppTheme.textPrimary : AppTheme.textMuted,
                              fontSize: r.sp(16),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action buttons
                  Column(
                    children: [
                      // Sample Button (Always available for testing)
                      TextButton.icon(
                        onPressed: provider.isScanning ? null : () => _handleScan(isSample: true),
                        icon: const Icon(Icons.bug_report_outlined),
                        label: const Text('TRY SAMPLE MALWARE'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: (_selectedFile == null || provider.isScanning) ? null : () => _handleScan(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: AppTheme.accentCyan,
                          foregroundColor: AppTheme.primaryDark,
                        ),
                        child: const Text('START REAL SCAN'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: provider.isScanning ? null : () {
                          // Bundle demo logic if they want to try bundled
                          // For now we just allow real pick
                        },
                        child: Text(
                          provider.isUsingDemoMode 
                              ? 'Demo Mode Active (Simulation)' 
                              : 'Connected to Live Engine',
                          style: TextStyle(
                            color: provider.isUsingDemoMode ? Colors.orange : AppTheme.benignGreen,
                            fontSize: r.sp(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
