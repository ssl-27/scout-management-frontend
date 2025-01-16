import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  String? _token;
  String? _userRole;
  Map<String, dynamic>? _userData;

  AuthStatus get status => _status;
  String? get token => _token;
  String? get userRole => _userRole;
  Map<String, dynamic>? get userData => _userData;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _token = await _storage.getToken();
    if (_token != null) {
      _userRole = await _storage.getUserRole();
      final userDataStr = await _storage.getUserData();
      if (userDataStr != null) {
        _userData = json.decode(userDataStr);
      }
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      final response = await _authService.verifyOtp(email, otp);

      // Parse JWT token to get user role and data
      final parts = response.split('.');
      final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );

      await _storage.saveToken(response);
      await _storage.saveUserRole(payload['group']);
      await _storage.saveUserData(json.encode(payload));

      _token = response;
      _userRole = payload['group'];
      _userData = payload;
      _status = AuthStatus.authenticated;

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    _token = null;
    _userRole = null;
    _userData = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}