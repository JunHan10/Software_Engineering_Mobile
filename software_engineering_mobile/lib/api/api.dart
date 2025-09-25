import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    // Default values for emulator/simulator
    if (Platform.isAndroid) return 'http://10.0.2.2:3000'; // Android emulator
    if (Platform.isIOS) return 'http://localhost:3000';     // iOS simulator
    return 'http://127.0.0.1:3000';
  }

  static String get login => '$baseUrl/login';
  static String get register => '$baseUrl/register';
}
