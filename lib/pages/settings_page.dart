import 'package:flutter/material.dart';

import '../style.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyAppStyle.menuMainColor,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: const Text("Configure morning routine"),
              onTap: () {
                Navigator.pushNamed(context, '/settings/mrconfig');
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: const Text("Configure evening routine"),
              onTap: () {
                Navigator.pushNamed(context, '/settings/erconfig');
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        ],
      ),
    );
  }
}