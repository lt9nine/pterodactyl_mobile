import 'package:flutter/material.dart';

class ServerStateUtil {
  /// Returns the color associated with the server state.
  static Color getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'running':
        return Colors.green;
      case 'starting':
        return Colors.orange;
      case 'stopping':
        return Colors.red;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }
}
