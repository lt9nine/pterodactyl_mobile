import 'package:flutter/material.dart';
import 'package:pterodactyl_mobile/theme/theme_manager.dart';
import 'package:pterodactyl_mobile/util/api.dart';
import 'package:pterodactyl_mobile/util/get_string_from_shared_preferences.dart';
import 'package:pterodactyl_mobile/util/get_bool_from_shared_preferences.dart';
import 'package:pterodactyl_mobile/util/text_input_dialog.dart';

class Settings extends StatefulWidget {
  final ThemeManager themeManager;

  const Settings({super.key, required this.themeManager});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String apiKey = "";
  String baseUrl = "";
  bool darkMode = false;

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
    getBoolFromSharedPreferences('dark_mode').then((value) {
      setState(() {
        darkMode = value;
      });
      widget.themeManager.toggleTheme(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: ListView(
        children: [
          SizedBox(height: 40),
          Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 10),
              Text('General Settings', style: TextStyle(fontSize: 20)),
            ],
          ),
          Divider(height: 20, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: Text('Dark Mode', style: TextStyle(fontSize: 18))),
              Switch(
                value: darkMode,
                onChanged: (value) {
                  setBoolToSharedPreferences("dark_mode", value);
                  setState(() {
                    darkMode = value;
                  });
                  widget.themeManager.toggleTheme(value);
                },
              ),
            ],
          ),
          SizedBox(height: 40),
          Row(
            children: [
              Icon(Icons.api),
              SizedBox(width: 10),
              Text('API Settings', style: TextStyle(fontSize: 20)),
            ],
          ),
          Divider(height: 20, thickness: 1),
          SizedBox(height: 10),
          buildExpandableSettingsItem(context, "Set Base URL"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
            child: Row(
              children: [
                Text('URL: '),
                Flexible(
                  child: Text(
                    baseUrl,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          buildExpandableSettingsItem(context, "Set API Key"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
            child: Row(
              children: [
                Text('Key: '),
                Flexible(
                  child: Text(
                    apiKey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: ElevatedButton(
              onPressed: () => testConnection(context, baseUrl, apiKey),
              child: Text('Test Connection'),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  GestureDetector buildExpandableSettingsItem(
      BuildContext context, String title) {
    return GestureDetector(
        onTap: () async {
          if (title == 'Set API Key') {
            String? newKey = await showTextInputDialog(context);
            if (newKey != null) {
              setStringToSharedPreferences('api_key', newKey);
              setState(() {
                apiKey = newKey;
              });
            }
          } else if (title == 'Set Base URL') {
            String? newUrl = await showTextInputDialog(context);
            if (newUrl != null) {
              setStringToSharedPreferences('base_url', newUrl);
              setState(() {
                baseUrl = newUrl;
              });
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 18)),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ));
  }
}
