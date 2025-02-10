import 'package:flutter/material.dart';
import 'package:pterodactyl_mobile/util/api.dart';

class Servers extends StatelessWidget {
  Servers({super.key});

  final apiService = ApiService(
    baseUrl: "",
    apiKey: "",
  );

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Servers'));
  }
}
