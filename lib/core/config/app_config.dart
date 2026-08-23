import 'package:flutter/foundation.dart';

enum Environment { dev, prod }

class AppConfig {
  // Master Render Backend URL (Single source of truth matching Vercel web app)
  static const String prodBaseUrl =
      'https://adamamaterials-e-commerce.onrender.com/api/v1';
  static const String devBaseUrl =
      'https://adamamaterials-e-commerce.onrender.com/api/v1';

  static String get baseUrl => prodBaseUrl;
}
