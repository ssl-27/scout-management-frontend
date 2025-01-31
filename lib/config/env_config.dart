class EnvConfig {
  static const String local = 'local';
  static const String dev = 'dev';
  static const String prod = 'prod';

  static String environment = const String.fromEnvironment('ENV', defaultValue: local);

  static String get apiBaseUrl {
    switch (environment) {
      case local:
        return 'http://localhost:3000';
      case dev:
        return 'https://scout-management-api-450043626382.asia-east2.run.app';  // Your dev backend URL
      case prod:
        return 'https://api.your-domain.com';      // Your prod backend URL
      default:
        return 'http://localhost:3000';
    }
  }

  // Add other environment-specific configurations here
  static Map<String, dynamic> get config {
    return {
      'apiBaseUrl': apiBaseUrl,
      'environment': environment,
      // Add other config values
    };
  }
}