/// API Configuration Constants
/// Change [baseUrl] to point to your backend server

class ApiConfig {
  // ⚠️ DEV MODE - Set to true to skip backend and use mock responses
  // Set to false to use real backend at baseUrl
  static const bool devMode = false;
  
  // Backend base URL - change this to your actual backend URL
  static const String baseUrl = 'http://localhost:5000';
  
  // Endpoints
  static const String healthEndpoint = '/health';
  static const String predictEndpoint = '/predict';
  static const String predictPlaystoreEndpoint = '/predict-playstore';
  
  // Timeouts (in milliseconds)
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 60000;
  static const int sendTimeout = 60000;
}
