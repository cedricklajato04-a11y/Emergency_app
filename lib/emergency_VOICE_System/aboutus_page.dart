import 'package:flutter/material.dart';
import 'emergency_menu.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 199, 199),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(214, 184, 23, 23),
        title: const Text("About Us"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Icon
            Center(
              child: Column(
                children: const [
                  Icon(Icons.local_hospital, size: 80, color: Color.fromARGB(214, 184, 23, 23)),
                  SizedBox(height: 12),
                  Text(
                    "Emergency Voice System",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Version 1.0",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App Description
            const Text(
              "About the App",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Emergency Voice System is a mobile application designed to help users quickly access emergency services such as Police, Hospital, and Fire Department. It also allows users to add custom contacts, submit feedback, and manage settings for a personalized experience.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            // Features
            const Text(
              "Key Features",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "• Quick access to emergency services\n"
              "• Add custom emergency contacts\n"
              "• Submit feedback directly from the app\n"
              "• Manage notifications and theme settings\n"
              "• Secure user profile management",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            // Developer Info
            const Text(
              "Developer",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Developed by: CS PHANTOM\n"
              "Contact: developer@example.com\n"
              "© 2026 Emergency Voice System. All rights reserved.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
