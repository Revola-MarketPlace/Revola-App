import 'package:flutter/foundation.dart';

enum Environment { dev, prod }

class AppConfig {
  // Production Render Backend URL (The primary source of truth used by Revola Web)
  static const String prodBaseUrl = 'https://adamamaterials-e-commerce.onrender.com/api/v1';

  // Development Base URL (Local Node.js backend on port 5000)
  static const String devBaseUrl = 'http://127.0.0.1:5000/api/v1';

  // Production release APK builds automatically point to the deployed Render backend
  static String get baseUrl => kReleaseMode ? prodBaseUrl : devBaseUrl;
}
