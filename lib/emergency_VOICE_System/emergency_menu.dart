import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'custom_contacts.dart';
import 'feedback_page.dart';
import 'settings_page.dart';
import 'aboutus_page.dart';
import '../auth/auth_service.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/fallback_numbers.dart';
import 'package:url_launcher/url_launcher.dart';


// 🔹 EMERGENCY DASHBOARD PAGE
class EmergencyMenuPage extends StatefulWidget {
  final List<Map<String, String>> contacts;
  const EmergencyMenuPage({super.key, required this.contacts});

  @override
  State<EmergencyMenuPage> createState() => _EmergencyMenuPageState();
}

class _EmergencyMenuPageState extends State<EmergencyMenuPage> {
  
  //supabase client
  void _showEmergencyContacts(String type) async {
  if (userId == null) return;

  final response = await supabase
      .from('custom_contacts')
      .select()
      .eq('user_id', userId!)
      .eq('type', type);

      // Check if response is a list of maps

  final contacts = List<Map<String, dynamic>>.from(response); // Cast response to list of maps

  showModalBottomSheet( // Show contacts in a bottom sheet
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: contacts.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min, 
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$type Contacts",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Emergency Hotline"),
                    subtitle: Text(
                      "Fallback Number: ${FallbackNumbers.getByType(type)}", // Show fallback number if no custom contacts are found
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Calling ${FallbackNumbers.getByType(type)}...", // Show fallback number in snackbar when tapped
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            : Column( // Show custom contacts if they exist
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$type Contacts",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ListView.builder( // List custom contacts
                    shrinkWrap: true,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(contact['name']),
                        subtitle: Text(
                          "${contact['number']}\n${contact['location']}",
                        ),
                        isThreeLine: true,
                        onTap: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Calling ${contact['name']}..."),
                            ),
                          );

                          final Uri phoneUri = Uri(
                            scheme: 'tel',
                            path: contact['phone'], // e.g. "1234567890"
                          );

                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Could not open phone dialer"),
                              ),
                            );
                          }
                        }
                      );
                    },
                  ),
                ],
              ),
      );
    },
  );
}



  //--------------------------------LOCTION HANDLING--------------------------------
  //location variables
  Position? _currentPosition;
  String? _locationError;
  bool _isLoadingLocation = true;

  Future<void> _getUserLocation() async { // Method to get user location with error handling
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled(); // Check if location services are enabled
    if (!serviceEnabled) {
      setState(() {
        _locationError = "Location services are disabled";
        _isLoadingLocation = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission(); // Check location permissions
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = "Location permission denied";
          _isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) { // Permissions are permanently denied, handle appropriately
      setState(() {
        _locationError = "Location permission permanently denied";
        _isLoadingLocation = false;
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition( // Request high accuracy location
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() { // Update state with the retrieved position
      _currentPosition = position;
      _isLoadingLocation = false;
    });
  } catch (e) { // Handle any errors that occur during location retrieval
    setState(() {
      _locationError = "Failed to get location";
      _isLoadingLocation = false;
    });
  }
}

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
  _loadUser(); // Load user data on init
  _getUserLocation(); // Get user location on init
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
            _drawerItem(Icons.history, "Log History"),
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
            Padding( //location display
              padding: const EdgeInsets.all(16),
              child: _isLoadingLocation
                  ? const CircularProgressIndicator()
                  : _locationError != null
                      ? Text(
                          _locationError!,
                          style: const TextStyle(color: Color.fromARGB(255, 255, 106, 106)),
                        )
                      : Column(
                          children: [
                            const Text(
                              "📍 Your Location",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Latitude: ${_currentPosition!.latitude}",
                            ),
                            Text(
                              "Longitude: ${_currentPosition!.longitude}",
                            ),
                          ],
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
            Expanded(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
            child: EmergencyBox(
              icon: Icons.local_police,
              label: "Police",
              color: const Color.fromARGB(255, 0, 140, 255),
              onPressed: () {
                _showEmergencyContacts("Police");
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: EmergencyBox(
              icon: Icons.local_hospital,
              label: "Hospital",
              color: const Color.fromARGB(255, 68, 163, 71),
              onPressed: () {
                _showEmergencyContacts("Hospital");
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: EmergencyBox(
              icon: Icons.local_fire_department,
              label: "Fire Station",
              color: const Color.fromARGB(255, 241, 59, 46),
              onPressed: () {
                _showEmergencyContacts("Fire Station");
              },
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
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CustomContactsPage()),
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

// 🔹 EMERGENCY BOX
class EmergencyBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed; // Callback for when the box is pressed

  const EmergencyBox({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: onPressed, // 👈 USE THIS
        child: Container(
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
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
