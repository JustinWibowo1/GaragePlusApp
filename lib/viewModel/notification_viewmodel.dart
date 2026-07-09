import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_kerja_models.dart';
import '../models/customer_models.dart';
import '../services/customer_services.dart';

// ─────────────────────────────────────────────────────────────
//  Model: Service Reminder Notification
// ─────────────────────────────────────────────────────────────

/// Satu item notifikasi berisi info customer + info reminder KM/bulan
class NotificationItem {
  final Customer customer;
  final ServiceReminderItem reminder;

  const NotificationItem({
    required this.customer,
    required this.reminder,
  });

  bool get isOverdue => reminder.isOverdue;
  bool get isUrgent => reminder.isUrgent;
}

// ─────────────────────────────────────────────────────────────
//  Model: Follow-Up Notification
// ─────────────────────────────────────────────────────────────

/// Item follow-up: pelanggan yang 7 hari lalu telah selesai service
class FollowUpItem {
  final String customerId;
  final int nomorWo;
  final String catatanKeluhan;
  final DateTime tanggalSelesai;
  final DateTime tanggalFollowup;
  final int hariSejakFollowup;
  final String namaPemilik;
  final String nomorPolisi;
  final String? noTelepon;
  final String jenisMobil;
  final String tipeMobil;
  final String nomorRangka;

  const FollowUpItem({
    required this.customerId,
    required this.nomorWo,
    required this.catatanKeluhan,
    required this.tanggalSelesai,
    required this.tanggalFollowup,
    required this.hariSejakFollowup,
    required this.namaPemilik,
    required this.nomorPolisi,
    this.noTelepon,
    required this.jenisMobil,
    required this.tipeMobil,
    required this.nomorRangka,
  });

  factory FollowUpItem.fromJson(Map<String, dynamic> json) {
    return FollowUpItem(
      customerId        : json['customer_id'] as String,
      nomorWo           : json['nomor_wo'] as int,
      catatanKeluhan    : json['catatan_keluhan'] as String? ?? '',
      tanggalSelesai    : DateTime.parse(json['tanggal_selesai'] as String),
      tanggalFollowup   : DateTime.parse(json['tanggal_followup'] as String),
      hariSejakFollowup : json['hari_sejak_followup'] as int? ?? 0,
      namaPemilik       : json['nama_pemilik'] as String,
      nomorPolisi       : json['nomor_polisi'] as String,
      noTelepon         : json['no_telepon'] as String?,
      jenisMobil        : json['jenis_mobil'] as String,
      tipeMobil         : json['tipe_mobil'] as String,
      nomorRangka       : json['nomor_rangka'] as String,
    );
  }

  String get nomorWoDisplay =>
      'WO-${tanggalSelesai.year}-${nomorWo.toString().padLeft(4, '0')}';
}

// ─────────────────────────────────────────────────────────────
//  ViewModel
// ─────────────────────────────────────────────────────────────

class NotificationViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _carService = CarService();

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  // ── Service Reminders ────────────────────────────────────────
  List<NotificationItem> _reminderItems = [];
  List<NotificationItem> get reminderItems => _reminderItems;

  int get overdueCount => _reminderItems.where((i) => i.isOverdue).length;
  int get urgentCount =>
      _reminderItems.where((i) => i.isUrgent && !i.isOverdue).length;

  /// Reminder dikelompokkan per Customer
  Map<Customer, List<ServiceReminderItem>> get groupedByCustomer {
    final map = <String, MapEntry<Customer, List<ServiceReminderItem>>>{};
    for (final item in _reminderItems) {
      final id = item.customer.nomorRangka;
      if (!map.containsKey(id)) {
        map[id] = MapEntry(item.customer, []);
      }
      map[id]!.value.add(item.reminder);
    }
    return {
      for (final entry in map.values) entry.key: entry.value,
    };
  }

  // ── Follow-Up ────────────────────────────────────────────────
  List<FollowUpItem> _followUpItems = [];
  List<FollowUpItem> get followUpItems => _followUpItems;

  // ── State ────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalBadgeCount => overdueCount + _followUpItems.length;

  // ── Load ─────────────────────────────────────────────────────
  Future<void> muatSemuaNotifikasi() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _muatServiceReminders(),
        _muatFollowUp(),
      ]);
    } catch (e) {
      _errorMessage = 'Gagal memuat notifikasi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _muatServiceReminders() async {
    try {
      final remindersRaw = await _supabase
          .from('v_service_reminders')
          .select('*');

      final allCustomers = await _carService.fetchAllCars();
      final customerMap = {for (final c in allCustomers) c.nomorRangka: c};

      final result = <NotificationItem>[];
      for (final raw in remindersRaw) {
        final customerId = raw['customer_id'] as String?;
        if (customerId == null) continue;
        final customer = customerMap[customerId];
        if (customer == null) continue;

        final reminder = ServiceReminderItem.fromJson(raw);
        if (reminder.isOverdue || reminder.isUrgent) {
          result.add(NotificationItem(customer: customer, reminder: reminder));
        }
      }

      // Urutkan: overdue dulu, lalu urgent
      result.sort((a, b) {
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;
        return 0;
      });

      _reminderItems = result;
    } catch (_) {
      _reminderItems = [];
    }
  }

  Future<void> _muatFollowUp() async {
    try {
      final raw = await _supabase
          .from('v_followup_reminders')
          .select('*');

      _followUpItems = (raw as List)
          .map((item) => FollowUpItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _followUpItems = [];
    }
  }
}
