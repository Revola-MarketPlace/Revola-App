enum Environment { dev, prod }

class AppConfig {
  static Environment environment = Environment.prod;

  // Development Base URL (10.0.2.2 for Android Emulator, localhost for desktop/web)
  static const String devBaseUrl = 'https://adamamaterials-e-commerce.onrender.com/api/v1';
  
  // Production Render Backend URL
  static const String prodBaseUrl = 'https://adamamaterials-e-commerce.onrender.com/api/v1';

  static String get baseUrl => environment == Environment.dev ? devBaseUrl : prodBaseUrl;
}
