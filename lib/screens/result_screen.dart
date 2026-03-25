import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/responsive.dart';
import '../models/scan_result.dart';
import 'home_screen.dart';

/// Result Screen - Comprehensive Scan Analysis display
class ResultScreen extends StatelessWidget {
  final ScanResult result;
  final String scanType;
  final String identifier;

  const ResultScreen({
    super.key,
    required this.result,
    required this.scanType,
    required this.identifier,
  });

  Color _getRiskColor() {
    final level = result.riskLevel.toLowerCase();
    if (level == 'low') return AppTheme.benignGreen;
    if (level == 'medium') return Colors.orange;
    if (level == 'high') return AppTheme.malwareRed;
    if (level == 'critical') return const Color(0xFFD32F2F);
    return result.isMalware ? AppTheme.malwareRed : AppTheme.benignGreen;
  }

  void _shareResult() {
    final text = 'AndroBlight Scan Report\n'
        'File: ${result.metadata?.fileName ?? identifier}\n'
        'Label: ${result.label}\n'
        'Confidence: ${result.confidencePercent}%\n'
        'Scan result powered by AndroBlight Security Engine.';
    Share.share(text);
  }

  void _downloadReport() async {
    final sha = result.metadata?.sha256;
    if (sha == null) return;
    
    // Use the base URL from config and ensure it's a direct browser download
    final url = Uri.parse('${ApiConfig.baseUrl}/report/$sha');
    
    try {
      // Use externalApplication mode to ensure the browser handles the download correctly
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // Fallback if external application launch fails
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final riskColor = _getRiskColor();
    
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: CustomScrollView(
        slivers: [
          // Elegant Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryLight,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: _shareResult,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [riskColor.withAlpha(80), AppTheme.primaryDark],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        result.isMalware ? Icons.security_update_warning_rounded : Icons.verified_user_rounded,
                        size: 64,
                        color: riskColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        result.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: r.sp(32),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Stats Row
                  Row(
                    children: [
                      _buildStatCard('Safety Score', '${result.overallScore ?? (result.isMalware ? 15 : 95)}/100', Colors.cyan, r),
                      const SizedBox(width: 12),
                      _buildStatCard('Confidence', '${result.confidencePercent}%', riskColor, r),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Malware Family (if exists)
                  if (result.malwareFamily != null) ...[
                    _buildSectionHeader('Threat Analysis', Icons.biotech_outlined),
                    _buildAnalysisCard(
                      title: 'Category: ${result.malwareFamily!.family}',
                      content: result.malwareFamily!.description,
                      color: AppTheme.malwareRed,
                      r: r,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Recommendations
                  if (result.recommendations != null && result.recommendations!.isNotEmpty) ...[
                    _buildSectionHeader('Smart Recommendations', Icons.tips_and_updates_outlined),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: result.recommendations!.map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline, size: 18, color: riskColor),
                              const SizedBox(width: 12),
                              Expanded(child: Text(rec, style: const TextStyle(color: Colors.white70))),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Permission Analysis
                  if (result.permissionAnalysis != null) ...[
                    _buildSectionHeader('Permission Analysis', Icons.lock_outline),
                    _buildPermissionSummary(result.permissionAnalysis!, r),
                    const SizedBox(height: 24),
                  ],

                  // APK Metadata
                  _buildSectionHeader('Technical Metadata', Icons.info_outline),
                  _buildMetadataTable(result, r),
                  
                  const SizedBox(height: 32),
                  
                  // Report Action
                  if (result.metadata?.sha256 != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _downloadReport,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('DOWNLOAD PDF REPORT'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withAlpha(50)),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (_) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppTheme.accentCyan,
                        foregroundColor: AppTheme.primaryDark,
                      ),
                      child: const Text('BACK TO HOME'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, Responsive r) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: AppTheme.textMuted, fontSize: r.sp(12))),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: r.sp(22), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.accentCyan),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard({required String title, required String content, required Color color, required Responsive r}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: r.sp(16))),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPermissionSummary(PermissionAnalysis analysis, Responsive r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildPermissionRow('Total Permissions', analysis.totalCount.toString(), Colors.white70),
          _buildPermissionRow('Critical Risk', analysis.critical.length.toString(), AppTheme.malwareRed),
          _buildPermissionRow('High Risk', analysis.high.length.toString(), Colors.orange),
          if (analysis.suspiciousCombos.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 24),
            ...analysis.suspiciousCombos.map((combo) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, size: 16, color: Colors.yellow),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Suspicious: ${combo.threat}',
                      style: const TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMetadataTable(ScanResult result, Responsive r) {
    final meta = result.metadata;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMetaRow('File Name', meta?.fileName ?? 'unknown'),
          _buildMetaRow('Size', meta?.fileSizeReadable ?? 'unknown'),
          _buildMetaRow('Package', meta?.packageName ?? 'unknown'),
          _buildMetaRow('Version', meta?.versionName ?? 'unknown'),
          _buildMetaRow('SHA256', (meta?.sha256 != null && meta!.sha256!.length > 12) ? meta.sha256!.substring(0, 12) + '...' : 'unknown'),
          if (result.certificate != null)
            _buildMetaRow('Signed', result.certificate!.signed ? 'YES (Trusted)' : 'NO', color: result.certificate!.signed ? Colors.green : Colors.red),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, {Color color = Colors.white70}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12))),
          Expanded(child: Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
