import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final String apiKey;

  ApiService({required this.baseUrl, required this.apiKey});

  Future<http.Response> makeApiCall(String endpoint,
      {String method = 'GET', Map<String, dynamic>? body}) async {
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
}

Future<void> testConnection(
    BuildContext context, String baseUrl, String apiKey) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/application/servers'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Check if the response body contains expected data
      if (response.body.contains('data')) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Connection Test'),
            content: Text('Connection successful!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Connection Test'),
            content: Text(
                'Connection failed: Invalid API key or unexpected response.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Connection Test'),
          content: Text('Connection failed: ${response.reasonPhrase}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connection Test'),
        content: Text('Connection failed: $e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
