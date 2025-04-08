import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pterodactyl_mobile/util/api.dart';

class ServerNetgraph extends StatefulWidget {
  final String serverIdentifier;
  final String apiKey;
  final String baseUrl;

  const ServerNetgraph({
    super.key,
    required this.serverIdentifier,
    required this.apiKey,
    required this.baseUrl,
  });

  @override
  State<ServerNetgraph> createState() => _ServerNetgraphState();
}

class _ServerNetgraphState extends State<ServerNetgraph> {
  late ApiService apiService;
  List<FlSpot> inboundData = [];
  List<FlSpot> outboundData = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(baseUrl: widget.baseUrl, apiKey: widget.apiKey);

    // Fetch data initially
    _fetchNetgraphData();

    // Set up a timer to refresh every 3 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchNetgraphData();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNetgraphData() async {
    try {
      final response =
          await apiService.getServerResources(widget.serverIdentifier);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resources = data['attributes']['resources'];

        // Extract network_rx_bytes and network_tx_bytes
        final int networkRxBytes = resources['network_rx_bytes'];
        final int networkTxBytes = resources['network_tx_bytes'];

        // Use the current timestamp for the data point
        final DateTime currentTimestamp = DateTime.now();

        setState(() {
          // Add the new data points (convert bytes to kilobytes)
          inboundData.add(FlSpot(
            currentTimestamp.millisecondsSinceEpoch.toDouble(),
            (networkRxBytes / 1024).toDouble(), // Convert to KB
          ));
          outboundData.add(FlSpot(
            currentTimestamp.millisecondsSinceEpoch.toDouble(),
            (networkTxBytes / 1024).toDouble(), // Convert to KB
          ));

          // Keep only the last 10 data points for better visualization
          if (inboundData.length > 10) inboundData.removeAt(0);
          if (outboundData.length > 10) outboundData.removeAt(0);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch netgraph data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total inbound and outbound traffic in MB
    final double totalInbound = inboundData.isNotEmpty
        ? inboundData.last.y / 1024 // Convert KB to MB
        : 0.0;
    final double totalOutbound = outboundData.isNotEmpty
        ? outboundData.last.y / 1024 // Convert KB to MB
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Netgraph'),
      ),
      body: Column(
        children: [
          // Netgraph as a square
          AspectRatio(
            aspectRatio: 1, // Makes the graph a square
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: inboundData,
                      isCurved: true,
                      color: Colors.blue, // Solid color for inbound
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false), // No shaded area
                    ),
                    LineChartBarData(
                      spots: outboundData,
                      isCurved: true,
                      color: Colors.red, // Solid color for outbound
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false), // No shaded area
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(0)} KB', // Display in KB
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt());
                          return Text(
                            '${date.minute}:${date.second}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: false), // Hide top axis labels
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: false), // Hide right axis labels
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine:
                        false, // Simplify by removing vertical lines
                    horizontalInterval: 100, // Fewer horizontal lines
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Legend below the graph
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 5),
                    const Text('Inbound (KB)'),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 5),
                    const Text('Outbound (KB)'),
                  ],
                ),
              ],
            ),
          ),
          // Total inbound and outbound traffic cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Inbound Traffic Card
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Total Inbound',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${totalInbound.toStringAsFixed(2)} MB',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Outbound Traffic Card
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Total Outbound',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${totalOutbound.toStringAsFixed(2)} MB',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
