import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../services/storage_service.dart';

class MeetingService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  MeetingService() {
    _dio.options.baseUrl = EnvConfig.apiBaseUrl; // Your backend URL
  }

  Future<void> _setAuthHeader() async {
    final token = await _storage.getToken();
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<dynamic>> getAllMeetings() async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/Meeting');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createMeeting(Map<String, dynamic> meetingData) async {
    await _setAuthHeader();
    try {
      final response = await _dio.post('/Meeting', data: meetingData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateMeeting(String id, Map<String, dynamic> meetingData) async {
    await _setAuthHeader();
    try {
      final response = await _dio.patch('/Meeting/$id', data: meetingData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMeeting(String id) async {
    await _setAuthHeader();
    try {
      await _dio.delete('/Meeting/$id');
    } catch (e) {
      rethrow;
    }
  }
}