import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/scan_result.dart';

/// API Service - HTTP Client using Dio

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectionTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for logging (debug mode)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  /// Health check - GET /health
  /// Returns false if server is unreachable (for demo mode fallback)
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(
        ApiConfig.healthEndpoint,
        options: Options(
          // Quick timeout for health check
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return data['status'] == 'ok';
      }
      return false;
    } on DioException catch (_) {
      // Return false instead of throwing - server is offline
      return false;
    }
  }

  /// Scan APK file - POST /predict
  Future<ScanResult> scanApk(
    File file, {
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await _dio.post(
        ApiConfig.predictEndpoint,
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200) {
        return ScanResult.fromJson(response.data);
      }
      throw ServerException('Unexpected response from server');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Scan Play Store app - POST /predict-playstore
  Future<ScanResult> scanPlayStore({
    String? packageName,
    String? url,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (url != null && url.isNotEmpty) {
        body['url'] = url;
      } else if (packageName != null && packageName.isNotEmpty) {
        body['package'] = packageName;
      } else {
        throw InvalidInputException('Please provide a package name or URL');
      }

      final response = await _dio.post(
        ApiConfig.predictPlaystoreEndpoint,
        data: body,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return ScanResult.fromJson(response.data);
      }
      throw ServerException('Unexpected response from server');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['error'] ?? 
                        e.response?.data?['message'] ?? 
                        'Server error occurred';
        if (statusCode == 400) {
          return InvalidInputException(message.toString());
        }
        if (statusCode == 404) {
          return ApiException('Resource not found', statusCode: statusCode);
        }
        if (statusCode != null && statusCode >= 500) {
          return ServerException(message.toString());
        }
        return ApiException(message.toString(), statusCode: statusCode);
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled');
      default:
        return NetworkException(e.message ?? 'An unexpected error occurred');
    }
  }
}
