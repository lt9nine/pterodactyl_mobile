import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pterodactyl_mobile/util/get_string_from_shared_preferences.dart';
import 'package:pterodactyl_mobile/util/api.dart';
import 'package:pterodactyl_mobile/pages/server_detail.dart';

class Servers extends StatefulWidget {
  const Servers({super.key});

  @override
  State<Servers> createState() => _ServersState();
}

class _ServersState extends State<Servers> {
  String apiKey = "";
  String baseUrl = "";

  @override
  void initState() {
    super.initState();

    getStringFromSharedPreferences('api_key').then((value) {
      setState(() {
        apiKey = value;
      });
    });

    getStringFromSharedPreferences('base_url').then((value) {
      setState(() {
        baseUrl = value;
      });
    });
  }

  Future<void> _refreshPage() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (apiKey == "" || baseUrl == "") {
      return const Center(child: Text('API key or base URL not set'));
    } else {
      ApiService apiService = ApiService(baseUrl: baseUrl, apiKey: apiKey);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Servers'),
        ),
        body: FutureBuilder(
          future: apiService.getServers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No servers found'));
            } else {
              Map<String, dynamic> responseBody =
                  jsonDecode(snapshot.data!.body);
              List servers = responseBody['data'];
              return ListView.builder(
                itemCount: servers.length,
                itemBuilder: (context, index) {
                  var attributes = servers[index]['attributes'];
                  return FutureBuilder(
                    future:
                        apiService.getServerResources(attributes['identifier']),
                    builder: (context, statusSnapshot) {
                      if (statusSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (statusSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${statusSnapshot.error}'));
                      } else {
                        Map<String, dynamic> statusResponse =
                            jsonDecode(statusSnapshot.data!.body);
                        String status =
                            statusResponse['attributes']['current_state'];
                        Color statusColor;
                        switch (status) {
                          case 'running':
                            statusColor = Colors.green;
                            break;
                          case 'starting':
                            statusColor = Colors.orange;
                            break;
                          case 'stopping':
                            statusColor = Colors.orange;
                            break;
                          case 'offline':
                            statusColor = Colors.red;
                            break;
                          default:
                            statusColor = Colors.grey;
                        }
                        return Card(
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            title: Text(attributes['name']),
                            subtitle: Text(
                                '${attributes['identifier']}: ${attributes['description']}'),
                            trailing: Container(
                              width: 10,
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServerDetail(
                                    serverName: attributes['name'],
                                    serverIdentifier: attributes['identifier'],
                                    serverDescription:
                                        attributes['description'],
                                  ),
                                ),
                              ).then((_) {
                                // Call the refresh method when returning to the server list
                                _refreshPage();
                              });
                            },
                          ),
                        );
                      }
                    },
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _refreshPage,
          child: const Icon(Icons.refresh),
        ),
      );
    }
  }
}
