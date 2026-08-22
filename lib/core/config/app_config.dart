enum Environment { dev, prod }

class AppConfig {
  static Environment environment = Environment.dev;

  // Development Base URL (127.0.0.1 with ADB reverse port 5000 connects directly to PC backend)
  static const String devBaseUrl = 'http://127.0.0.1:5000/api/v1';
  
  // Production Render Backend URL
  static const String prodBaseUrl = 'https://adamamaterials-e-commerce.onrender.com/api/v1';

  static String get baseUrl => environment == Environment.dev ? devBaseUrl : prodBaseUrl;
}
