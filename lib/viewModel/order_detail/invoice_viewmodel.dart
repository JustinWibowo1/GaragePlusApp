import 'package:flutter/material.dart';
import '../../models/invoice_models.dart';
import '../../services/invoice_services.dart';
import '../../ui/dialogs/form_invoice.dart';
import '../../component/app_colors.dart';

class InvoiceViewModel extends ChangeNotifier {
  final InvoiceServices _service = InvoiceServices();

  List<InvoiceItem> daftarInvoice = [];
  bool isLoading = false;
  String? errorMessage;

  /// Mengambil total harga dari seluruh invoice item di dalam list
  int get totalInvoice {
    return daftarInvoice.fold(0, (sum, item) => sum + item.harga);
  }

  /// Memuat data invoice dari database berdasarkan Nomor WO
  Future<void> muatInvoice(int nomorWo) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      daftarInvoice = await _service.fetchByNomorWo(nomorWo);
    } catch (e) {
      errorMessage = 'Gagal memuat data invoice: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Menambahkan invoice baru ke database dan mengupdate list
  Future<bool> tambahInvoice({
    required int nomorWo,
    required String namaPekerjaan,
    required int harga,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final itemBaru = await _service.insertInvoice(
        nomorWo: nomorWo,
        namaPekerjaan: namaPekerjaan,
        harga: harga,
      );

      if (itemBaru != null) {
        // Tambahkan data ke tampilan tanpa perlu fetch ulang dari database
        daftarInvoice.add(itemBaru);
        return true;
      } else {
        errorMessage = 'Gagal menambahkan invoice.';
        return false;
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Menampilkan dialog tambah invoice dan memproses hasilnya (UI Logic)
  Future<void> showTambahInvoiceDialog(BuildContext context, int nomorWo) async {
    final hasil = await FormInvoiceDialog.show(context);
    if (hasil == null || !context.mounted) return;

    final nama = hasil['nama'] as String;
    final harga = hasil['harga'] as int;

    final sukses = await tambahInvoice(
      nomorWo: nomorWo,
      namaPekerjaan: nama,
      harga: harga,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sukses 
              ? '✅ Invoice "$nama" berhasil ditambahkan' 
              : '⚠️ Gagal menambahkan invoice'),
          backgroundColor: sukses ? AppColors.green : AppColors.urgentBg,
        )
      );
    }
  }

  /// Menghapus invoice berdasarkan ID dan mengupdate list
  Future<bool> hapusInvoice(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      final berhasil = await _service.deleteInvoice(id);
      
      if (berhasil) {
        // Hapus item dari list tampilan
        daftarInvoice.removeWhere((item) => item.id == id);
        return true;
      } else {
        errorMessage = 'Gagal menghapus invoice.';
        return false;
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
