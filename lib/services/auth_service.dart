import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000', // Change this to your backend URL
  ));

  Future<void> requestOtp(String email) async {
    try {
      await _dio.post('/auth/request-otp', data: {
        'email': email,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<String> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      return response.data['access_token'];
    } catch (e) {
      rethrow;
    }
  }
}