import 'package:flutter/material.dart';
import 'package:my_app/emergency_VOICE_System/Contacts/Custom_contacts.dart';
import 'package:my_app/emergency_VOICE_System/Contacts/EmegergencyContacts/emergency_contacts_page.dart';
import 'package:my_app/emergency_VOICE_System/UserDetails/userdetails_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../feedback_page.dart';
import '../Settings/settings_page.dart';
import '../AboutUs/aboutus_page.dart';
import '../../auth/auth_service.dart';
import 'package:my_app/services/location_service.dart';


// 🔹 EMERGENCY DASHBOARD PAGE
class EmergencyMenuPage extends StatefulWidget {
  
  final List<Map<String, String>> contacts;
  const EmergencyMenuPage({super.key, required this.contacts});

  @override
  State<EmergencyMenuPage> createState() => _EmergencyMenuPageState();
}




class _EmergencyMenuPageState extends State<EmergencyMenuPage> {
  
  // State variables for location and address
  String? _address;
  bool _isLoadingAddress = false;


 




  //auth service

  final AuthService _authService = AuthService();
  

  //state variable 
  final supabase = Supabase.instance.client;

  String? userEmail;
  String? userId;
  bool isLoading = true;

  //fetch user data
  Future<void> _loadUser() async {
  final user = supabase.auth.currentUser;

    if (user == null) {
      // Safety fallback
      return;
    }

    setState(() {
      userId = user.id;
      userEmail = user.email;
      isLoading = false;
    });
  }

@override
void initState() {
  super.initState();
  _loadUser();
  _initLocationFlow();
}

Future<void> _initLocationFlow() async {
  if (!mounted) return;

  setState(() => _isLoadingAddress = true);

  try {
    final pos = await LocationService.refresh();  

    if (pos == null) {
      setState(() {
        _address = LocationService.lastError ?? "Location not available";
      });
      return;
    }

    //  Convert to address (with timeout)
    String? addr;
    try {
      addr = await LocationService.getAddressFromPosition(pos)
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      addr = "Address lookup failed (check internet)";
    }

    //  SAVE TO DB (with timeout + catch)
    try {
      await LocationService.saveToDatabase(
        userId: supabase.auth.currentUser!.id, 
        pos: pos,
        address: addr,
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      // If saving fails, still show address (don’t freeze)
      debugPrint("Save location failed: $e");
    }

    if (!mounted) return;
    setState(() {
      _address = addr ?? "Address not available";
    });
  } finally {
    // ignore: control_flow_in_finally
    if (!mounted) return;
    setState(() => _isLoadingAddress = false);
  }
}


  // 🔹 LOGOUT HANDLER
  Future<void> _handleLogout(BuildContext context) async {
    await _authService.signOut();
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      // APP BAR
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(214, 184, 23, 23),
        title: const Text(
          "DASHBOARD",
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
                    child: const Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEmail ?? "USER",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserDetailsPage(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "View Details",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _drawerItem(Icons.contacts, "Custom Contacts"),
            _drawerItem(Icons.feedback, "Feedback"),
            _drawerItem(Icons.info, "About Us"),
            _drawerItem(Icons.settings, "Settings"),
            const Divider(),
            _drawerItem(Icons.logout, "Log Out"),
          ],
        ),
      ),

      // BODY
      body: SafeArea(
        child: Column(
          children: [
            Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color.fromARGB(214, 184, 23, 23),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) {
                  final pos = LocationService.lastKnownPosition;
                  final err = LocationService.lastError;

                  if (err != null) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_off, color: Color.fromARGB(214, 184, 23, 23)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            err,
                            style: const TextStyle(
                              color: Color.fromARGB(214, 184, 23, 23),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (pos == null) {
                    return const Row(
                      children: [
                        Icon(Icons.location_searching, color: Color.fromARGB(214, 184, 23, 23)),
                        SizedBox(width: 10),
                        Text("Getting location..."),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Color.fromARGB(214, 184, 23, 23)),
                          SizedBox(width: 8),
                          Text(
                            "Current Location",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Address
                      Text(
                        _isLoadingAddress
                            ? "Converting coordinates to address..."
                            : (_address ?? "Address not available"),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Lat/Lng (small)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Lat: ${pos.latitude.toStringAsFixed(5)}",
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Lng: ${pos.longitude.toStringAsFixed(5)}",
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
            const SizedBox(height: 40),
            Column(
              children: [
                const Icon(Icons.person, size: 120),
                const SizedBox(height: 12),
                Text(
                  userEmail ?? "USER",
                  style: const TextStyle(
                      fontSize: 35, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: EmergencyIconButton(
                        icon: Icons.local_police,
                        color: const Color.fromARGB(255, 9, 63, 107),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmergencyContactsPage(
                                title: "Police Contacts",
                                contactType: "police",
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: EmergencyIconButton(
                        icon: Icons.local_hospital,
                        color: const Color.fromARGB(255, 3, 117, 6),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmergencyContactsPage(
                                title: "Hospital Contacts",
                                contactType: "hospital",
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: EmergencyIconButton(
                        icon: Icons.local_fire_department,
                        color: const Color.fromARGB(255, 124, 22, 15),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmergencyContactsPage(
                                title: "Fire Station Contacts",
                                contactType: "fire",
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔹 DRAWER ITEM LOGIC
  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () async {
        Navigator.pop(context);
        switch (title) {
          case "Log Out":
            await _handleLogout(context);
            break;
          case "Custom Contacts":
            Navigator.push(context,
              MaterialPageRoute(
                builder: (_) => const CustomContactsPage()),
            );
            break;
          case "Emergency Contacts":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmergencyContactsPage(
                  title: "Emergency Contacts",
                  contactType: "police",
                ),
              ),
            );
            break;
          case "Feedback":
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FeedbackPage()));
            break;
          case "Settings":
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsPage()));
            break;
          case "About Us":
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutUsPage()));
            break;
          case "view details":
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const UserDetailsPage()));
            break;
        }
      },
    );
  }
}

// 🔹 EMERGENCY BUTTON WIDGET
class EmergencyIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const EmergencyIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Icon(
          icon,
          size: 30,
        ),
      ),
    );
  }
}