/// AppConfig — Konfigurasi aplikasi yang dibaca dari --dart-define saat build/run.
///
/// Cara menjalankan dengan credentials:
///   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_...
///
/// Atau buat launch.json di VSCode (lihat README untuk panduan lengkap).
library;

class AppConfig {
  AppConfig._(); // Tidak bisa di-instantiate

  /// URL endpoint Supabase project Anda.
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // Kosong → akan error saat init, mengingatkan developer
  );

  /// Anon/public key Supabase (bukan service_role key!).
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Validasi semua konfigurasi wajib sudah terisi.
  /// Panggil ini di main() sebelum inisialisasi.
  static void validate() {
    final errors = <String>[];
    if (supabaseUrl.isEmpty) {
      errors.add('SUPABASE_URL belum diset. Tambahkan --dart-define=SUPABASE_URL=...');
    }
    if (supabaseAnonKey.isEmpty) {
      errors.add('SUPABASE_ANON_KEY belum diset. Tambahkan --dart-define=SUPABASE_ANON_KEY=...');
    }
    if (errors.isNotEmpty) {
      throw StateError('❌ Konfigurasi tidak lengkap:\n${errors.join('\n')}');
    }
  }
}
