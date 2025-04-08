import 'package:flutter/material.dart';
import 'package:pterodactyl_mobile/util/api.dart';
import 'package:pterodactyl_mobile/util/notification_util.dart';

class ServerSendCommandsPage extends StatefulWidget {
  final String serverIdentifier;
  final String apiKey;
  final String baseUrl;

  const ServerSendCommandsPage({
    super.key,
    required this.serverIdentifier,
    required this.apiKey,
    required this.baseUrl,
  });

  @override
  _ServerSendCommandsPageState createState() => _ServerSendCommandsPageState();
}

class _ServerSendCommandsPageState extends State<ServerSendCommandsPage> {
  final TextEditingController _commandController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) {
      NotificationUtil.showSnackBar(context, 'Please enter a command');
      return;
    }

    setState(() {
      _isSending = true;
    });

    ApiService apiService = ApiService(
      baseUrl: widget.baseUrl,
      apiKey: widget.apiKey,
    );

    try {
      final response =
          await apiService.sendCommand(widget.serverIdentifier, command);
      if (response.statusCode == 204) {
        NotificationUtil.showSnackBar(context, 'Command sent successfully');
        _commandController.clear();
      } else {
        NotificationUtil.showSnackBar(
          context,
          'Failed to send command: ${response.body}',
        );
      }
    } catch (e) {
      NotificationUtil.showSnackBar(context, 'Error: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Commands'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _commandController,
              decoration: const InputDecoration(
                labelText: 'Enter Command',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendCommand(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSending ? null : _sendCommand,
              child: _isSending
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Send Command'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }
}
