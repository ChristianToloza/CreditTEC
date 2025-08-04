import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _token;
  String? get token => _token;

  String? _userName;
  String? get userName => _userName;

  String? _profileImageUrl;
  String? get profileImageUrl => _profileImageUrl;

  static const String _tokenKey = 'authToken';
  static const String _userNameKey = 'userName';
  static const String _profileImageUrlKey = 'profileImageUrl';

  AuthViewModel() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_tokenKey)) {
      _token = prefs.getString(_tokenKey);
      _userName = prefs.getString(_userNameKey);
      _profileImageUrl = prefs.getString(_profileImageUrlKey);

      if (_token != null && _token!.isNotEmpty) {
        _isAuthenticated = true;
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _authService.login(email, password);

      _token = responseData['token'] as String?;

      _userName = responseData['nombre'] as String?;
      _profileImageUrl = responseData['profileImageUrl'] as String?;

      if (_token != null && _token!.isNotEmpty) {
        _isAuthenticated = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
        if (_userName != null) {
          await prefs.setString(_userNameKey, _userName!);
        }
        if (_profileImageUrl != null) {
          await prefs.setString(_profileImageUrlKey, _profileImageUrl!);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            responseData['message'] as String? ??
            'No se recibió un token válido del servidor.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _userName = null;
    _profileImageUrl = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_profileImageUrlKey);

    notifyListeners();
  }

  Future<bool> register({
    required String nombres,
    required String apellido1,
    String? apellido2,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _authService.register(
        nombres: nombres,
        apellido1: apellido1,
        apellido2: apellido2,
        email: email,
        password: password,
      );

      _isLoading = false;

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
