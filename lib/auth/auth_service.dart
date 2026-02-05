import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;  

  // Sign in with email and password
Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    ); 
  }
  // Sign up with email and password and fullname
  Future<AuthResponse> signUpWithEmailPassword(String email, String password,String fullname) async {
    return await _supabase.auth.signUp(
      
      email: email,
      password: password,
      data: {
      'full_name': fullname,
      }
    );
  }
  // Sign out
Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  // Get user email
String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

}
