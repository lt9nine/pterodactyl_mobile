import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final String apiKey;

  ApiService({required this.baseUrl, required this.apiKey});

  Future<http.Response> makeApiCall(String endpoint, {String method = 'GET', Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    switch (method.toUpperCase()) {
      case 'POST':
        return await http.post(url, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return await http.put(url, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return await http.delete(url, headers: headers);
      case 'GET':
      default:
        return await http.get(url, headers: headers);
    }
  }

  Future<bool> validateApiKey(String key) async {
    final url = Uri.parse('$baseUrl/validate_key');
    final headers = {
      'Authorization': 'Bearer $key',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);
    return response.statusCode == 200;
  }
}