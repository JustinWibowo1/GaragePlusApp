import 'package:flutter/material.dart';
import '../../component/app_colors.dart';

class StatusPopup {
  /// Menampilkan popup status (berhasil/gagal) di tengah layar,
  /// dan akan tertutup secara otomatis setelah [durationSeconds] detik.
  static Future<void> show(
    BuildContext context, {
    required bool isSuccess,
    required String message,
    int durationSeconds = 3,
  }) async {
    bool isClosed = false;

    await showDialog(
      context: context,
      barrierDismissible: true, // pengguna bisa menutup lebih cepat dgn tap di luar
      builder: (BuildContext ctx) {
        // Auto-close timer
        Future.delayed(Duration(seconds: durationSeconds), () {
          if (ctx.mounted && !isClosed) {
            isClosed = true;
            Navigator.of(ctx).pop();
          }
        });

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            isClosed = true; // Tandai jika user menutup manual
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ikon Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSuccess ? AppColors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess ? Icons.check_circle : Icons.cancel,
                      color: isSuccess ? AppColors.green : Colors.red,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Judul
                  Text(
                    isSuccess ? 'Berhasil!' : 'Gagal!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Pesan
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
