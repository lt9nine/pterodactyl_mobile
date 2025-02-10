import 'package:flutter/material.dart';
import 'package:pterodactyl_mobile/util/get_string_from_shared_preferences.dart';
import 'package:pterodactyl_mobile/util/text_input_dialog.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: ListView(
        children: [
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
              children: [Text('Current URL: '), Text(baseUrl)],
            ),
          ),
          buildExpandableSettingsItem(context, "Set API Key"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
            child: Row(
              children: [Text('Current Key: '), Text(apiKey)],
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
