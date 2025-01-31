import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../services/storage_service.dart';

class AttendanceService {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  AttendanceService() {
    _dio.options.baseUrl = EnvConfig.apiBaseUrl; // Your backend URL
  }

  Future<void> _setAuthHeader() async {
    final token = await _storage.getToken();
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<dynamic>> getMeetingAttendance(String meetingId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/attendances/meeting/$meetingId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAttendance(String meetingId, String scoutId, String status) async {
    await _setAuthHeader();
    try {
      await _dio.post('/attendances', data: {
        'meetingId': meetingId,
        'scoutId': scoutId,
        'attendance': status,
        'meetingDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
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

  Future<List<dynamic>> findAllForMember(String memberId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/attendances/my-records');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> findByMeetingAndPatrol(String meetingId, String patrol) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/attendances/meeting/$meetingId/patrol/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createSelfAttendance(Map<String, dynamic> data) async {
    await _setAuthHeader();
    try {
      await _dio.post('/attendances', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> findAllForGuardianChildren(String guardianId) async {
    await _setAuthHeader();
    try {
      final response = await _dio.get('/attendances/children');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}