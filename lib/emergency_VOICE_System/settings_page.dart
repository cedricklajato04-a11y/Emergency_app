import 'package:flutter/material.dart';
import '../constants/fallback_numbers.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(214, 184, 23, 23),
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fallback Emergency Numbers",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "These numbers are used when no custom contacts are available.\n"
              "They will be automatically updated based on your country in future versions.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            _fallbackTile("Police", FallbackNumbers.police),
            _fallbackTile("Hospital", FallbackNumbers.hospital),
            _fallbackTile("Fire Station", FallbackNumbers.fireStation),

            const SizedBox(height: 24),

            
          ],
        ),
      ),
    );
  }

  Widget _fallbackTile(String label, String number) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.phone),
        title: Text(label),
        trailing: Text(
          number,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
