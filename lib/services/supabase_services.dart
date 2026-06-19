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
          'role': role, // ← gunakan parameter, bukan hardcode 'admin'
        });
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      rethrow;
    }
  }
}
