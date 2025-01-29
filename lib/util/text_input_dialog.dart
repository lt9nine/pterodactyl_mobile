import 'package:flutter/material.dart';

final _textFieldController = TextEditingController();

Future<String?> showTextInputDialog(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set API Key'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: ""),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("CANCEL"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () =>
                  Navigator.pop(context, _textFieldController.text),
            ),
          ],
        );
      });
}
