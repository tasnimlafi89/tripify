import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class HealthService {
  static Future<bool> checkBackend() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/public/health"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["status"] == "UP";
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
