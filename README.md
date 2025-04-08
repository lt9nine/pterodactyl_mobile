# Pterodactyl Mobile

A Flutter-based mobile application for managing Pterodactyl servers.

## Features
- View server details and status.
- Start, stop, and restart servers.
- Monitor server resource usage.
- Send commands to servers.

## Screenshots
![alt text](image.png)
![alt text](image-1.png)
![alt text](image-2.png)

## License
This project is for educational purposes only.

## Development

### Key Classes and Methods

#### `PteroMainApp` ([lib/main.dart](lib/main.dart))
- **Description**: The main entry point of the application.
- **Methods**:
  - `initState`: Initializes the app and sets the theme based on user preferences.
  - `dispose`: Cleans up listeners when the app is closed.

#### `ServerDetail` ([lib/pages/server_detail.dart](lib/pages/server_detail.dart))
- **Description**: Displays detailed information about a specific server.
- **Methods**:
  - `_sendServerCommand(String command)`: Sends a command (e.g., start, stop, restart) to the server.
  - `NavigationButton`: Navigates to pages like "Send Commands" or "Show Netgraph."

#### `ServerNetgraph` ([lib/pages/server_netgraph.dart](lib/pages/server_netgraph.dart))
- **Description**: Displays a network graph for monitoring server traffic.
- **Key Features**:
  - Uses `FlGridData` and `FlBorderData` to render the graph.
  - Includes a legend for inbound and outbound traffic.

#### `Servers` ([lib/pages/servers.dart](lib/pages/servers.dart))
- **Description**: Displays a list of servers.
- **Methods**:
  - `_refreshPage()`: Refreshes the server list.
  - `onTap`: Navigates to the `ServerDetail` page for a selected server.

#### `Settings` ([lib/pages/settings.dart](lib/pages/settings.dart))
- **Description**: Allows users to configure API settings.
- **Key Features**:
  - `buildExpandableSettingsItem`: Creates expandable settings for API key and base URL.
  - Displays the current API key and base URL.

#### `ResourceCard` ([lib/pages/server_detail.dart](lib/pages/server_detail.dart))
- **Description**: A reusable widget for displaying resource usage (e.g., memory, CPU, disk).
- **Key Features**:
  - Displays an icon, title, and formatted resource usage.