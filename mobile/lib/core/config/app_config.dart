class AppConfig {
  static const bool useMockData = bool.fromEnvironment('USE_MOCK_DATA', defaultValue: false);
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/api',
  );
}
