import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pterodactyl_mobile/util/notification_util.dart';

class ApiService {
  final String baseUrl;
  final String apiKey;

  ApiService({required this.baseUrl, required this.apiKey});

  Future<http.Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      return response;
    }
  }

  Future<http.Response> post(String endpoint, String body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      return response;
    }
  }

  Future<http.Response> getServers() async { // Retrieves all servers
    return await get('/api/client');
  }

  Future<http.Response> getServerResources(String serverIdentifier) async { // Retrieves servers resources (specific server)
    return await get('/api/client/servers/$serverIdentifier/resources');
  }

  Future<http.Response> sendCommand( // Sends command to server
      String serverIdentifier, String command) async {
    final endpoint = '/api/client/servers/$serverIdentifier/command';
    final body = {'command': command};

    return await post(endpoint, jsonEncode(body));
  }

  Future<http.Response> sendSignal( // Sends signal to server (start, stop, restart)
      String serverIdentifier, String command) async {
    final endpoint = '/api/client/servers/$serverIdentifier/power';
    final body = {'signal': command};

    return await post(endpoint, jsonEncode(body));
  }
}

Future<void> testConnection( // Tests the connection to the Pterodactyl API (Settings.dart)
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
      if (response.body.contains('data')) {
        NotificationUtil.showDialogMessage(
          context,
          title: 'Connection Test',
          message: 'Connection successful!',
        );
      } else {
        NotificationUtil.showDialogMessage(
          context,
          title: 'Connection Test',
          message: 'Connection failed: Invalid API key or unexpected response.',
        );
      }
    } else {
      NotificationUtil.showDialogMessage(
        context,
        title: 'Connection Test',
        message: 'Connection failed: ${response.reasonPhrase}',
      );
    }
  } catch (e) {
    NotificationUtil.showDialogMessage(
      context,
      title: 'Connection Test',
      message: 'Connection failed: $e',
    );
  }
}
