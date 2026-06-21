import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class IpLookupService {
  IpLookupService._();

  static const String _url = 'https://api.ipify.org?format=json';

  /// Fetches the caller's current public IP. Returns null on failure.
  static Future<String?> fetchPublicIp() async {
    try {
      final response = await http
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['ip'] as String?;
    } catch (_) {
      return null;
    }
  }
}
