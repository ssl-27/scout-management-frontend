// lib/config/app_config.dart
class EnvConfig {
  static const String local = 'local';
  static const String dev = 'dev';
  static const String prod = 'prod';

  // Environment
  static final String environment = const String.fromEnvironment(
    'ENV',
    defaultValue: local,
  );

  // API Configuration
  static final String apiBaseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  // // Authentication
  // static final String authSecret = const String.fromEnvironment(
  //   'AUTH_SECRET',
  //   defaultValue: '',
  // );
  //
  // // Other sensitive configurations
  // static final String firebaseApiKey = const String.fromEnvironment(
  //   'FIREBASE_API_KEY',
  //   defaultValue: '',
  // );

  // Public configurations that can vary by environment
  static Map<String, dynamic> get publicConfig {
    switch (environment) {
      case dev:
        return {
          'maxUploadSize': 10485760, // 10MB
          'allowedFileTypes': ['jpg', 'png', 'pdf'],
          'maxConcurrentUploads': 3,
        };
      case prod:
        return {
          'maxUploadSize': 5242880, // 5MB
          'allowedFileTypes': ['jpg', 'png'],
          'maxConcurrentUploads': 2,
        };
      default:
        return {
          'maxUploadSize': 20971520, // 20MB
          'allowedFileTypes': ['jpg', 'png', 'pdf', 'doc'],
          'maxConcurrentUploads': 5,
        };
    }
  }

  // Helper method to get complete config
  static Map<String, dynamic> get config {
    return {
      'environment': environment,
      'apiBaseUrl': apiBaseUrl,
      ...publicConfig,
    };
  }
}