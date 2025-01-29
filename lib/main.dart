import 'package:flutter/material.dart';
import 'package:pterodactyl_mobile/pages/dashboard.dart';
import 'package:pterodactyl_mobile/pages/servers.dart';
import 'package:pterodactyl_mobile/pages/settings.dart';
import 'package:pterodactyl_mobile/theme/theme_constants.dart';
import 'package:pterodactyl_mobile/theme/theme_manager.dart';

void main() {
  runApp(PteroMainApp());
}

ThemeManager _themeManager = ThemeManager();

class PteroMainApp extends StatefulWidget {
  const PteroMainApp({super.key});

  @override
  State<PteroMainApp> createState() => _PteroMainAppState();
}

class _PteroMainAppState extends State<PteroMainApp> {
  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    _themeManager.addListener(themeListener);
    super.initState();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  int _selectedIndex = 0;
  List<Widget> body = [
    Dashboard(),
    Servers(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeManager.themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Pterodactyl')),
        ),
        body: body[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 0
                      ? Icons.dashboard
                      : Icons.dashboard_outlined),
                  label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 1
                      ? Icons.desktop_windows
                      : Icons.desktop_windows_outlined),
                  label: 'Servers'),
              BottomNavigationBarItem(
                  icon: Icon(_selectedIndex == 2
                      ? Icons.settings
                      : Icons.settings_outlined),
                  label: 'Settings'),
            ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _themeManager
                .toggleTheme(_themeManager.themeMode == ThemeMode.light);
          },
          child: Icon(Icons.dark_mode),
        ),
      ),
    );
  }
}
