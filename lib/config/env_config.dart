/// Environment Configuration
///
/// Bu dosya hassas bilgileri içermez - sadece varsayılan değerler
/// Gerçek environment değerleri için .env dosyası kullanın
library;

class EnvConfig {
  // Admin credentials - Production'da .env'den alınmalı
  static const String adminEmail = String.fromEnvironment(
    'ADMIN_EMAIL',
    defaultValue: 'root',
  );

  static const String adminPassword = String.fromEnvironment(
    'ADMIN_PASSWORD',
    defaultValue: 'admin123',
  );

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // Weather API Key
  static const String weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE',
  );

  // Development mode
  static const bool isDevelopment = bool.fromEnvironment(
    'DEVELOPMENT',
    defaultValue: true,
  );
}
