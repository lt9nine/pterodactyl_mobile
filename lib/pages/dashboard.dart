import 'dart:convert';
import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pterodactyl_mobile/util/api.dart';
import 'package:pterodactyl_mobile/util/get_string_from_shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String apiKey = "";
  String baseUrl = "";
  int runningServers = 0;
  int stoppedServers = 0;
  int restartingServers = 0;
  bool isLoading = true;
  double cpuUsage = 0.0;
  Timer? _refreshTimer; // Timer for auto-refresh

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
    _startAutoRefresh(); // Start the auto-refresh timer
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      setState(() {
        isLoading = true; // Show loading indicator during refresh
      });
      await _fetchDashboardData(); // Refresh data every 10 seconds
    });
  }

  Future<void> _initializeDashboard() async {
    try {
      // Fetch apiKey and baseUrl from shared preferences
      final fetchedApiKey = await getStringFromSharedPreferences('api_key');
      final fetchedBaseUrl = await getStringFromSharedPreferences('base_url');

      if (fetchedApiKey.isEmpty || fetchedBaseUrl.isEmpty) {
        throw Exception('API key or Base URL is missing');
      }

      setState(() {
        apiKey = fetchedApiKey;
        baseUrl = fetchedBaseUrl;
      });

      // Fetch dashboard data after apiKey and baseUrl are set
      await _fetchDashboardData();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error initializing dashboard: ${e.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  Future<void> _fetchDashboardData() async {
    try {
      final apiService = ApiService(baseUrl: baseUrl, apiKey: apiKey);
      final response = await apiService.getServers();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final servers = data['data'];

        int runningCount = 0;
        int stoppedCount = 0;
        int restartingCount = 0;

        double totalCpuUsage = 0.0;

        // Fetch resources for each server
        for (var server in servers) {
          final serverId = server['attributes']['identifier'];
          final resourcesResponse =
              await apiService.getServerResources(serverId);

          if (resourcesResponse.statusCode == 200) {
            final resourcesData = jsonDecode(resourcesResponse.body);
            final currentState = resourcesData['attributes']['current_state'];

            // Update server state counts
            if (currentState == 'running') {
              runningCount++;
              // Update CPU usage totals only for running servers
              final resources = resourcesData['attributes']['resources'];
              totalCpuUsage += (resources['cpu_absolute'] ?? 0.0);
            } else if (currentState == 'offline') {
              stoppedCount++;
            } else if (currentState == 'starting' ||
                currentState == 'stopping') {
              restartingCount++;
            }
          }
        }

        // Calculate average CPU usage only for running servers
        final averageCpuUsage =
            runningCount > 0 ? totalCpuUsage / runningCount : 0.0;

        setState(() {
          runningServers = runningCount;
          stoppedServers = stoppedCount;
          restartingServers = restartingCount;

          cpuUsage =
              averageCpuUsage / 100; // Convert to fraction for progress bar

          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch server list');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dashboard data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Running Servers Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Server Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200, // Set a fixed height for the chart
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  if (runningServers > 0)
                                    PieChartSectionData(
                                      value: runningServers.toDouble(),
                                      color: Colors.green,
                                      title: '$runningServers Running',
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  if (stoppedServers > 0)
                                    PieChartSectionData(
                                      value: stoppedServers.toDouble(),
                                      color: Colors.red,
                                      title: '$stoppedServers Stopped',
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  if (restartingServers > 0)
                                    PieChartSectionData(
                                      value: restartingServers.toDouble(),
                                      color: Colors.yellow,
                                      title: '$restartingServers Restarting',
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resource Usage Overview',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: cpuUsage, // Example: 70% CPU usage
                            backgroundColor: Colors.grey[300],
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'CPU Usage: ${(cpuUsage * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          await _fetchDashboardData();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
