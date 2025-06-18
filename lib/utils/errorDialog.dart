import 'package:flutter/material.dart';

import '../main.dart';

void MyDialog(
    {BuildContext? context,
      required String title,
      required String message,
      required String okText}) {

  showDialog(
      context: navigationKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          actions: [
            InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    okText,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ))
          ],
          title: Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: TextStyle(),
          ),
        );
      });
}
