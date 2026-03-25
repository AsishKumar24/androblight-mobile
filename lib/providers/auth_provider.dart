import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// Auth Provider - Authentication state management

enum AuthState { initial, authenticated, unauthenticated, loading, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  String? _userEmail;
  String? _displayName;

  AuthProvider(this._authService);

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _userEmail;
  String? get displayName => _displayName;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  /// Initialize — check if user is already logged in
  Future<void> init() async {
    await _authService.init();
    
    if (_authService.isLoggedIn) {
      _state = AuthState.authenticated;
      _userEmail = _authService.userEmail;
      _displayName = _authService.displayName;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Register a new account
  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      _state = AuthState.authenticated;
      final user = response['user'];
      _userEmail = user?['email'];
      _displayName = user?['display_name'];
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Login with credentials
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      _state = AuthState.authenticated;
      final user = response['user'];
      _userEmail = user?['email'];
      _displayName = user?['display_name'];
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _state = AuthState.unauthenticated;
    _userEmail = null;
    _displayName = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
