class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'CORE_API_BASE_URL',
    defaultValue: 'https://appbanco-banbif-core.onrender.com/api/v1',
  );

  static String get normalizedBaseUrl => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
}
