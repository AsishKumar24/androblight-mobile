/// Scan Result Model - Enhanced API Response
/// Handles the comprehensive response from the enhanced backend

class ScanResult {
  final String label;
  final double confidence;
  final int? overallScore;
  final String? threatLevel;
  final List<String>? recommendations;
  final PermissionAnalysis? permissionAnalysis;
  final MalwareFamily? malwareFamily;
  final CertificateInfo? certificate;
  final ApkMetadata? metadata;

  ScanResult({
    required this.label,
    required this.confidence,
    this.overallScore,
    this.threatLevel,
    this.recommendations,
    this.permissionAnalysis,
    this.malwareFamily,
    this.certificate,
    this.metadata,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    // Handle both simple and enhanced response formats
    String label;
    double confidence;
    
    if (json.containsKey('ml_detection')) {
      // Enhanced backend response
      final mlDetection = json['ml_detection'] as Map<String, dynamic>;
      label = mlDetection['label'] as String? ?? 'Unknown';
      confidence = (mlDetection['confidence'] as num? ?? 0.0).toDouble();
    } else {
      // Simple response (label directly in root)
      label = json['label'] as String? ?? 'Unknown';
      confidence = (json['confidence'] as num? ?? 0.0).toDouble();
    }
    
    return ScanResult(
      label: label,
      confidence: confidence,
      overallScore: json['overall_score'] as int?,
      threatLevel: json['threat_level'] as String?,
      recommendations: json['recommendations'] != null
          ? (json['recommendations'] as List).map((e) => e.toString()).toList()
          : (json['recommendation'] != null 
             ? (json['recommendation'] as List).map((e) => e.toString()).toList()
             : null),
      permissionAnalysis: json['permission_analysis'] != null
          ? PermissionAnalysis.fromJson(json['permission_analysis'])
          : null,
      malwareFamily: json.containsKey('ml_detection') && 
                     json['ml_detection']['malware_family'] != null
          ? MalwareFamily.fromJson(json['ml_detection']['malware_family'])
          : null,
      certificate: json['certificate'] != null
          ? CertificateInfo.fromJson(json['certificate'])
          : null,
      metadata: json['metadata'] != null
          ? ApkMetadata.fromJson(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'overall_score': overallScore,
      'threat_level': threatLevel,
      'recommendations': recommendations,
      'metadata': metadata?.toJson(),
    };
  }

  bool get isMalware => label.toLowerCase() == 'malware';
  bool get isBenign => label.toLowerCase() == 'benign';
  
  int get confidencePercent => (confidence * 100).round();
  
  // Risk level based on overall score (0-100, where 100 is safest)
  // Thresholds aligned with backend (app_enhanced.py:767-774)
  String get riskLevel {
    if (overallScore == null) return threatLevel ?? 'unknown';
    if (overallScore! >= 70) return 'low';
    if (overallScore! >= 50) return 'medium';
    if (overallScore! >= 30) return 'high';
    return 'critical';
  }
}

/// APK Metadata from enhanced backend
class ApkMetadata {
  final String? fileName;
  final String? sha256;
  final String? md5;
  final int? fileSize;
  final String? fileSizeReadable;
  final String? scanTimestamp;
  final String? mainActivity;
  final String? packageName;
  final String? versionName;

  ApkMetadata({
    this.fileName,
    this.sha256,
    this.md5,
    this.fileSize,
    this.fileSizeReadable,
    this.scanTimestamp,
    this.mainActivity,
    this.packageName,
    this.versionName,
  });

  factory ApkMetadata.fromJson(Map<String, dynamic> json) {
    return ApkMetadata(
      fileName: json['file_name'] as String?,
      sha256: json['sha256'] as String?,
      md5: json['md5'] as String?,
      fileSize: json['file_size'] as int?,
      fileSizeReadable: json['file_size_readable'] as String?,
      scanTimestamp: json['scan_timestamp'] as String?,
      mainActivity: json['main_activity'] as String?,
      packageName: json['package_name'] as String?,
      versionName: json['version_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_name': fileName,
      'sha256': sha256,
      'file_size_readable': fileSizeReadable,
      'scan_timestamp': scanTimestamp,
    };
  }
}

/// Permission Analysis from enhanced backend
class PermissionAnalysis {
  final int totalCount;
  final int riskScore;
  final List<PermissionInfo> critical;
  final List<PermissionInfo> high;
  final List<PermissionInfo> medium;
  final List<SuspiciousCombo> suspiciousCombos;

  PermissionAnalysis({
    required this.totalCount,
    required this.riskScore,
    required this.critical,
    required this.high,
    required this.medium,
    required this.suspiciousCombos,
  });

  factory PermissionAnalysis.fromJson(Map<String, dynamic> json) {
    return PermissionAnalysis(
      totalCount: json['total_count'] as int? ?? 0,
      riskScore: json['risk_score'] as int? ?? 0,
      critical: (json['critical'] as List?)
              ?.map((e) => PermissionInfo.fromJson(e))
              .toList() ?? [],
      high: (json['high'] as List?)
              ?.map((e) => PermissionInfo.fromJson(e))
              .toList() ?? [],
      medium: (json['medium'] as List?)
              ?.map((e) => PermissionInfo.fromJson(e))
              .toList() ?? [],
      suspiciousCombos: (json['suspicious_combos'] as List?)
              ?.map((e) => SuspiciousCombo.fromJson(e))
              .toList() ?? [],
    );
  }
  
  int get dangerousCount => critical.length + high.length;
}

class PermissionInfo {
  final String permission;
  final String description;
  final String risk;

  PermissionInfo({
    required this.permission,
    required this.description,
    required this.risk,
  });

  factory PermissionInfo.fromJson(Map<String, dynamic> json) {
    return PermissionInfo(
      permission: json['permission'] as String? ?? '',
      description: json['description'] as String? ?? '',
      risk: json['risk'] as String? ?? '',
    );
  }
}

class SuspiciousCombo {
  final String threat;
  final String description;
  final List<String>? permissions;

  SuspiciousCombo({
    required this.threat,
    required this.description,
    this.permissions,
  });

  factory SuspiciousCombo.fromJson(Map<String, dynamic> json) {
    return SuspiciousCombo(
      threat: json['threat'] as String? ?? '',
      description: json['description'] as String? ?? '',
      permissions: (json['permissions'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}

class MalwareFamily {
  final String family;
  final String description;

  MalwareFamily({
    required this.family,
    required this.description,
  });

  factory MalwareFamily.fromJson(Map<String, dynamic> json) {
    return MalwareFamily(
      family: json['family'] as String? ?? 'unknown',
      description: json['description'] as String? ?? '',
    );
  }
}

class CertificateInfo {
  final bool signed;
  final bool debugSigned;
  final String? fingerprint;

  CertificateInfo({
    required this.signed,
    required this.debugSigned,
    this.fingerprint,
  });

  factory CertificateInfo.fromJson(Map<String, dynamic> json) {
    return CertificateInfo(
      signed: json['signed'] as bool? ?? false,
      debugSigned: json['debug_signed'] as bool? ?? false,
      fingerprint: json['fingerprint_sha256'] as String?,
    );
  }
}
