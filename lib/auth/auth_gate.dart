import 'package:flutter/material.dart';
import 'package:my_app/emergency_VOICE_System/Login_signup/login_user.dart';
import 'package:my_app/emergency_VOICE_System/Dashboard/emergency_menu.dart';
import 'package:my_app/services/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _locationInitialized = false;

  Future<void> _initLocationOnce() async {
    if (_locationInitialized) return;
    _locationInitialized = true;
    await LocationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // Initialize location ONCE after login (not inside build repeatedly)
          _initLocationOnce();

          return EmergencyMenuPage(contacts: []);
        } else {
          // reset so next login will init again
          _locationInitialized = false;
          return const LoginPage();
        }
      },
    );
  }
}