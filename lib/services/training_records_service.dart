import 'package:dio/dio.dart';
import '../services/storage_service.dart';

class TrainingRecordsService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  TrainingRecordsService() {
    _dio.options.baseUrl = 'http://localhost:3000';
  }

  Future<void> _setAuthHeader() async {
    final token = await _storage.getToken();
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<dynamic>> getAllTrainingRecords() async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/training-records');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getScoutTrainingRecords(String scoutId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/training-records/scout/$scoutId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> findAllByScoutId(String scoutId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/training-records/scout/$scoutId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAllScouts() async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/user-general/members');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getChildrenProgress(String guardianId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/training-records/children');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getChildBadgeProgress(String childId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/training-records/scout/$childId/badges');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}