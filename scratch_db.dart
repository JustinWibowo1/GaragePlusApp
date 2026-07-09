import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  try {
    final response = await Supabase.instance.client
        .from('v_service_reminders')
        .select('*')
        .limit(1);
    print('DB Result: $response');
  } catch (e) {
    print('Error: $e');
  }
}
