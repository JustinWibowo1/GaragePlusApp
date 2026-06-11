import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServices {
  final _supabase = Supabase.instance.client;

  Future<void> registerUser(
      String email, String password, String name, String role) async {
    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final String? newUserId = res.user?.id;

      if (newUserId != null) {
        await _supabase.from('user').insert({
          'id': newUserId,
          'name': name,
          'role': 'admin',
        });
        print('User successfully created!');
      }
    } catch (error) {
      print('Error creating user: $error');
      rethrow;
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('User successfully logged in!');
    } catch (error) {
      print('Error logging in user: $error');
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    try {
      await _supabase.auth.signOut();
      print('User has been logged out.');
    } catch (error) {
      print('Logout failed: $error');
    }
  }
}
