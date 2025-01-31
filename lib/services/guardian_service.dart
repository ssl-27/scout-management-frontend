import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../services/storage_service.dart';

class GuardianService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  GuardianService() {
    _dio.options.baseUrl = EnvConfig.apiBaseUrl; // Your backend URL
  }

  Future<void> _setAuthHeader() async {
    final token = await _storage.getToken();
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<dynamic>> getChildren(String guardianId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/user-general/guardian/$guardianId/children');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getChildDetails(String childId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/user-general/member/$childId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getChildrenBadges(String guardianId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/badge-progress/guardian/$guardianId/children');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}