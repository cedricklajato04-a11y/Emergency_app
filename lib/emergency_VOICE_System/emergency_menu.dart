import 'package:flutter/material.dart';
import 'login_user.dart';
import 'custom_contacts.dart';
import 'feedback_page.dart';
import 'settings_page.dart';
import 'aboutus_page.dart';

// 🔹 EMERGENCY DASHBOARD PAGE
class EmergencyMenuPage extends StatelessWidget {
  const EmergencyMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 199, 199),

      // APP BAR
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(214, 184, 23, 23),
        title: const Text(
          "EMERGENCY DASHBOARD",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),

      // DRAWER
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(226, 175, 23, 23),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color.fromARGB(255, 44, 44, 44),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "USER",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserDetailsPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "View Details",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Drawer Items
            drawerItem(Icons.contacts, "Custom Contacts", context),
            drawerItem(Icons.history, "Call Log History", context),
            drawerItem(Icons.feedback, "Feedback", context),
            drawerItem(Icons.info, "About Us", context),
            drawerItem(Icons.settings, "Settings", context),
            const Divider(),
            drawerItem(Icons.logout, "Log Out", context),
          ],
        ),
      ),

      // BODY
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Column(
              children: const [
                Icon(Icons.person,
                    size: 120,
                    color: Color.fromARGB(255, 44, 44, 44)),
                SizedBox(height: 12),
                Text(
                  "USER",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 51, 51, 51),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Emergency Buttons
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Expanded(
                      child: EmergencyBox(
                        icon: Icons.local_police,
                        label: "POLICE",
                        color: Color.fromARGB(255, 21, 135, 228),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: EmergencyBox(
                        icon: Icons.local_hospital,
                        label: "HOSPITAL",
                        color: Color.fromARGB(255, 68, 163, 71),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: EmergencyBox(
                        icon: Icons.local_fire_department,
                        label: "FIRE",
                        color: Color.fromARGB(255, 241, 59, 46),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 DRAWER ITEM LOGIC
  Widget drawerItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // close drawer

        switch (title) {
          case "Log Out":
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
            break;

          case "Custom Contacts":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomContactsPage()),
            );
            break;

          case "Feedback":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FeedbackPage()),
            );
            break;

          case "Settings":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
            break;

          case "About Us":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            );
            break;

          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title clicked")),
            );
        }
      },
    );
  }
}

// 🔹 EMERGENCY BOX
class EmergencyBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const EmergencyBox({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$label selected")),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 USER DETAILS PAGE
class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(214, 184, 23, 23),
        title: const Text("User Details"),
      ),
      body: const Center(
        child: Text(
          "User profile information goes here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
