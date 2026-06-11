import 'package:flutter/material.dart';
/// ```
abstract class AppColors {
  // ── Brand / Primary ──────────────────────────────────────────
  /// Biru navy utama — warna brand, header, tombol utama
  static const Color navy = Color(0xFF0F2042);

  /// Biru navy gelap — gradient, card dark
  static const Color navyDark = Color(0xFF0C1938);

  /// Biru navy lebih gelap — gradient stop kedua
  static const Color navyDeep = Color(0xFF142850);

  /// Biru navy paling gelap — overlay, pill
  static const Color navyDarkest = Color(0xFF0A1A3A);

  /// Biru primary (lebih cerah) — teks link, indikator aktif
  static const Color primaryBlue = Color(0xFF1E3A8A);

  // ── Background ───────────────────────────────────────────────
  /// Background utama layar — putih keabu-abuan
  static const Color background = Color(0xFFF8F9FB);

  /// Background alternatif — untuk card & screen mobile
  static const Color backgroundAlt = Color(0xFFF8FAFC);

  /// Background form input
  static const Color backgroundInput = Color(0xFFF0F2F8);

  /// Background header/section table
  static const Color backgroundSection = Color(0xFFF8F9FC);

  // ── Text ─────────────────────────────────────────────────────
  /// Teks gelap utama
  static const Color textDark = Color(0xFF1E293B);

  /// Teks abu — subtitle, placeholder
  static const Color textGrey = Color(0xFF64748B);

  // ── Green / Success ──────────────────────────────────────────
  /// Hijau aksen — tombol sukses, status selesai (mobile)
  static const Color green = Color(0xFF10B981);

  /// Hijau aksen — badge & indikator (desktop)
  static const Color greenAccent = Color(0xFF1D9E75);

  /// Hijau tua — teks pada badge "Selesai"
  static const Color greenDark = Color(0xFF1A6B4A);

  /// Hijau latar badge "Selesai"
  static const Color greenBg = Color(0xFFDCFCE7);

  /// Hijau tua — badge status selesai
  static const Color greenBadgeDark = Color(0xFF166534);

  /// Hijau terang — border/teks badge selesai
  static const Color greenBadgeLight = Color(0xFF66BB6A);

  /// Hijau latar — status selesai
  static const Color greenStatusBg = Color(0xFFE8F5E9);

  /// Hijau teks — status selesai
  static const Color greenStatusText = Color(0xFF1B5E20);

  // ── Orange / Warning / Reminder ──────────────────────────────
  /// Oranye utama — warning, reminder urgent
  static const Color orange = Color(0xFFFF9800);

  /// Oranye gelap — teks warning
  static const Color orangeDark = Color(0xFFE65100);

  /// Oranye badge — status "Menunggu"
  static const Color orangeBadge = Color(0xFFFFB74D);

  /// Latar badge "Menunggu"
  static const Color orangeStatusBg = Color(0xFFFFF3E0);

  /// Latar panel reminder km
  static const Color reminderBg = Color(0xFFFFF8F0);

  /// Border panel reminder km
  static const Color reminderBorder = Color(0xFFFFD080);

  /// Teks header reminder km
  static const Color reminderTitle = Color(0xFFBF6000);

  /// Teks isi reminder km
  static const Color reminderText = Color(0xFF8A5200);

  /// Latar badge "Segera" (urgent)
  static const Color urgentBg = Color(0xFFFEF9C3);

  /// Teks badge "Segera" (urgent)
  static const Color urgentText = Color(0xFF854D0E);

  // ── Red / Error / Overdue ────────────────────────────────────
  /// Merah — status overdue, error
  static const Color red = Color(0xFFD32F2F);

  /// Merah gelap — teks overdue
  static const Color redDark = Color(0xFFB71C1C);

  /// Merah muda — teks overdue (lighter)
  static const Color redLight = Color(0xFFE57373);

  /// Latar badge "Overdue"
  static const Color overdueBg = Color(0xFFFFEBEE);

  // ── Blue / Working ───────────────────────────────────────────
  /// Biru — status "Dikerjakan"
  static const Color blueWorking = Color(0xFF0D47A1);

  /// Biru terang — badge border "Dikerjakan"
  static const Color blueWorkingLight = Color(0xFF42A5F5);

  /// Biru latar badge "Dikerjakan"
  static const Color blueWorkingBg = Color(0xFFE3F2FD);

  /// Biru latar chip/tag
  static const Color blueChipBg = Color(0xFFDBEAFE);

  /// Biru link/WO number
  static const Color blueLink = Color(0xFF378ADD);

  /// Amber — status "in progress" item
  static const Color amber = Color(0xFFF59E0B);

  // ── Neutral / Grey ───────────────────────────────────────────
  /// Abu — status "Diambil", teks netral
  static const Color grey = Color(0xFF424242);

  /// Abu muda — border badge "Diambil"
  static const Color greyLight = Color(0xFFBDBDBD);

  /// Abu latar badge "Diambil"
  static const Color greyBg = Color(0xFFF5F5F5);

  /// Abu border — card & divider
  static const Color border = Color(0xFFE2E8F0);

  /// Abu teks completed item
  static const Color greyCompleted = Color(0xFF475569);

  /// Latar chip
  static const Color chipBg = Color(0xFFF1F5F9);

  // ── Status Badge: map lengkap ─────────────────────────────────
  // Gunakan AppStatusColors untuk badge status order
}

/// Helper untuk mendapatkan warna berdasarkan status order.
///
/// Contoh:
/// ```dart
/// final style = AppStatusColors.of('Menunggu');
/// Container(color: style.bg)
/// ```
class AppStatusColors {
  final Color bg;
  final Color text;
  final Color border;
  const AppStatusColors(this.bg, this.text, this.border);

  static const _map = <String, AppStatusColors>{
    'Menunggu'  : AppStatusColors(AppColors.orangeStatusBg, AppColors.orangeDark, AppColors.orangeBadge),
    'Dikerjakan': AppStatusColors(AppColors.blueWorkingBg,  AppColors.blueWorking, AppColors.blueWorkingLight),
    'Selesai'   : AppStatusColors(AppColors.greenStatusBg,  AppColors.greenStatusText, AppColors.greenBadgeLight),
    'Diambil'   : AppStatusColors(AppColors.greyBg,         AppColors.grey,        AppColors.greyLight),
  };

  static AppStatusColors of(String status) =>
      _map[status] ?? const AppStatusColors(AppColors.greyBg, AppColors.grey, AppColors.greyLight);

  static bool isPending(String status) =>
      status == 'Menunggu' || status == 'Dikerjakan';
}
