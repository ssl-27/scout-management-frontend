import 'package:dio/dio.dart';
import '../services/storage_service.dart';

class BadgeService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  BadgeService() {
    _dio.options.baseUrl = 'http://localhost:3000';
  }

  Future<void> _setAuthHeader() async {
    final token = await _storage.getToken();
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<dynamic>> getAllBadges() async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/badge-details');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createBadge(Map<String, dynamic> badgeData) async {
    await _setAuthHeader();
    try {
      final response = await _dio.post('/badge-details', data: badgeData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getTrainingItems(String badgeId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/training-items?badgeId=$badgeId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createTrainingItem(Map<String, dynamic> itemData) async {
    await _setAuthHeader();
    try {
      final response = await _dio.post('/training-items', data: itemData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getEarnedBadges(String scoutId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/badge-progress/scout/$scoutId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getBadgeDetails(String badgeId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/badge-details/$badgeId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAvailableBadges() async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/badge-details');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitBadgeWork(String badgeId, Map<String, dynamic> workData) async {
    await _setAuthHeader();
    try {
      await _dio.post('/badge-progress/submit/$badgeId', data: workData);
    } catch (e) {
      rethrow;
    }
  }
}