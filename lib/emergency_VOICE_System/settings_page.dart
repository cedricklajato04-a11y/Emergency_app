import 'package:flutter/material.dart';
import 'emergency_menu.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 199, 199),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(214, 184, 23, 23),
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 Personal Details
          ListTile(
            leading: const Icon(Icons.person, color: Color.fromARGB(214, 184, 23, 23)),
            title: const Text("Personal Details"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Personal Details clicked")),
              );
            },
          ),
          const Divider(),

          // 🔹 Password & Security
          ListTile(
            leading: const Icon(Icons.lock, color: Color.fromARGB(214, 184, 23, 23)),
            title: const Text("Password & Security"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password & Security clicked")),
              );
            },
          ),
          const Divider(),

          // 🔹 Profiles & Accounts
          ListTile(
            leading: const Icon(Icons.account_circle, color: Color.fromARGB(214, 184, 23, 23)),
            title: const Text("Profile & Accounts"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile & Accounts clicked")),
              );
            },
          ),
          const Divider(),

          // 🔹 Theme Setting
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Color.fromARGB(214, 184, 23, 23)),
            title: const Text("Dark Mode"),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isDarkMode ? "Dark Mode Enabled" : "Dark Mode Disabled"),
                  ),
                );
              },
            ),
          ),
          const Divider(),

          // 🔹 Notifications Setting
          ListTile(
            leading: const Icon(Icons.notifications, color: Color.fromARGB(214, 184, 23, 23)),
            title: const Text("Notifications"),
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(notificationsEnabled ? "Notifications Enabled" : "Notifications Disabled"),
                  ),
                );
              },
            ),
          ),
          const Divider(),

          // 🔹 About App
          ListTile(
            leading: const Icon(Icons.info, color: Color.fromARGB(214, 184, 23, 23)),
            title: const Text("About App"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Emergency Voice System",
                applicationVersion: "v1.0",
                applicationIcon: const Icon(Icons.local_hospital, size: 50, color: Color.fromARGB(214, 184, 23, 23)),
                children: const [
                  Text("This app allows you to quickly access emergency contacts, submit feedback, and more."),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
