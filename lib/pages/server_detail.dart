import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pterodactyl_mobile/pages/server_sendcommands.dart';
import 'package:pterodactyl_mobile/pages/server_netgraph.dart';
import 'package:pterodactyl_mobile/util/api.dart';
import 'package:pterodactyl_mobile/util/get_string_from_shared_preferences.dart';
import 'package:pterodactyl_mobile/util/notification_util.dart';
import 'package:pterodactyl_mobile/util/server_state_util.dart';
import 'package:pterodactyl_mobile/widgets/action_button.dart';
import 'package:pterodactyl_mobile/widgets/navigation_button.dart';
import 'package:pterodactyl_mobile/widgets/resource_card.dart';

class ServerDetail extends StatefulWidget {
  final String serverName;
  final String serverIdentifier;
  final String serverDescription;

  const ServerDetail({
    super.key,
    required this.serverName,
    required this.serverIdentifier,
    required this.serverDescription,
  });

  @override
  State<ServerDetail> createState() => _ServerDetailState();
}

class _ServerDetailState extends State<ServerDetail> {
  String apiKey = "";
  String baseUrl = "";
  Timer? _timer;

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

    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      _refreshPage();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refreshPage() async {
    setState(() {}); // Triggers a rebuild of the widget
  }

  Future<void> _sendServerCommand(String command) async {
    ApiService apiService = ApiService(baseUrl: baseUrl, apiKey: apiKey);
    try {
      final response =
          await apiService.sendSignal(widget.serverIdentifier, command);
      if (response.statusCode == 204) {
        NotificationUtil.showSnackBar(
          context,
          'Server $command command sent successfully',
        );
        _refreshPage(); // Refresh the page after a successful command
      } else {
        NotificationUtil.showSnackBar(
          context,
          'Failed to send $command command',
        );
      }
    } catch (e) {
      NotificationUtil.showSnackBar(
        context,
        'Error: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ApiService apiService = ApiService(baseUrl: baseUrl, apiKey: apiKey);

    return Scaffold(
      appBar: AppBar(title: Text(widget.serverName)),
      body: FutureBuilder(
        future: apiService.getServerResources(widget.serverIdentifier),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            // Parse the response data
            Map<String, dynamic> resourceData = jsonDecode(snapshot.data!.body);
            String serverState = resourceData['attributes']['current_state'];
            String memoryUsage = resourceData['attributes']['resources']
                    ['memory_bytes']
                .toString();
            String cpuUsage = resourceData['attributes']['resources']
                    ['cpu_absolute']
                .toString();
            String diskUsage = resourceData['attributes']['resources']
                    ['disk_bytes']
                .toString();

            // Determine the color for the server state
            Color stateColor = ServerStateUtil.getStateColor(serverState);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identifier: ${widget.serverIdentifier}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Description: ${widget.serverDescription}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  // Server State Card
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.info, color: stateColor),
                      title: const Text('Server State'),
                      subtitle: Text(serverState),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Memory Usage Card
                  ResourceCard(
                    icon: Icons.memory,
                    iconColor: Colors.blue,
                    title: 'Memory Usage',
                    subtitle:
                        '${(int.parse(memoryUsage) / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB',
                  ),
                  const SizedBox(height: 10),
                  // CPU Usage Card
                  ResourceCard(
                    icon: Icons.speed,
                    iconColor: Colors.orange,
                    title: 'CPU Usage',
                    subtitle: '$cpuUsage%',
                  ),
                  const SizedBox(height: 10),
                  // Disk Usage Card
                  ResourceCard(
                    icon: Icons.storage,
                    iconColor: Colors.green,
                    title: 'Disk Usage',
                    subtitle:
                        '${(int.parse(diskUsage) / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB',
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ActionButton(
                        label: 'Start',
                        color: Colors.green,
                        onPressed: () => _sendServerCommand('start'),
                      ),
                      const SizedBox(width: 10),
                      ActionButton(
                        label: 'Restart',
                        color: Colors.orange,
                        onPressed: () => _sendServerCommand('restart'),
                      ),
                      const SizedBox(width: 10),
                      ActionButton(
                        label: 'Stop',
                        color: Colors.red,
                        onPressed: () => _sendServerCommand('stop'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Open Console and Show Netgraph Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      NavigationButton(
                        label: 'Send Commands',
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServerSendCommandsPage(
                                serverIdentifier: widget.serverIdentifier,
                                apiKey: apiKey,
                                baseUrl: baseUrl,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      NavigationButton(
                        label: 'Show Netgraph',
                        color: Colors.purple,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServerNetgraph(
                                serverIdentifier: widget.serverIdentifier,
                                apiKey: apiKey,
                                baseUrl: baseUrl,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshPage, // Floating refresh button
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
