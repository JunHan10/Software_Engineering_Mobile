import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/connection_result.dart';

class NetworkUtils {
  /// Tests the connection to the server
  /// Returns a ConnectionResult with success flag and message
  static Future<ConnectionResult> testConnection() async {
    try {
      // First check internet connectivity
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          return const ConnectionResult(
            success: false,
            message: 'No internet connection',
          );
        }
      } on SocketException catch (_) {
        return const ConnectionResult(
          success: false,
          message: 'No internet connection',
        );
      }

      // Then check server connectivity
      try {
        final response = await http
            .get(Uri.parse('${AppConfig.baseUrl}/health'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          return const ConnectionResult(
            success: true,
            message: 'Connected to server successfully',
          );
        } else {
          return ConnectionResult(
            success: false,
            message: 'Server returned status code: ${response.statusCode}',
          );
        }
      } on SocketException catch (_) {
        return const ConnectionResult(
          success: false,
          message:
              'Could not connect to server. Please check:\n1. Server is running\n2. IP address is correct\n3. You are on the same network',
        );
      } on HttpException catch (e) {
        return ConnectionResult(
          success: false,
          message: 'HTTP Error: ${e.message}',
        );
      } on TimeoutException catch (_) {
        return const ConnectionResult(
          success: false,
          message: 'Connection timed out',
        );
      }
    } catch (e) {
      return ConnectionResult(success: false, message: 'Unexpected error: $e');
    }
  }

  /// Checks if we're running in an emulator
  static bool get isEmulator {
    if (Platform.isAndroid) {
      try {
        return Platform.environment.containsKey('ANDROID_EMULATOR');
      } catch (_) {
        return false;
      }
    }
    return false;
  }
}
