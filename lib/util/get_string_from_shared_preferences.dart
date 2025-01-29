import 'package:shared_preferences/shared_preferences.dart';

Future<String> getStringFromSharedPreferences(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? '';
}

Future<void> setStringToSharedPreferences(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}
