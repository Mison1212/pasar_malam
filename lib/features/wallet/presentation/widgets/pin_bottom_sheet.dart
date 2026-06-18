import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom Sheet untuk memasukkan PIN saat proses pembayaran.
/// Menampilkan 6 input digit PIN dengan keyboard custom.
///
/// Cara penggunaan:
/// ```dart
/// final pin = await PinBottomSheet.show(context, totalAmount: 150000);
/// if (pin != null) {
///   // User memasukkan PIN, lanjutkan proses pembayaran
/// }
/// ```
class PinBottomSheet extends StatefulWidget {
  final double totalAmount;

  const PinBottomSheet({super.key, required this.totalAmount});

  /// Menampilkan bottom sheet dan return PIN jika user submit, null jika cancel.
  static Future<String?> show(BuildContext context, {required double totalAmount}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PinBottomSheet(totalAmount: totalAmount),
    );
  }

  @override
  State<PinBottomSheet> createState() => _PinBottomSheetState();
}

class _PinBottomSheetState extends State<PinBottomSheet> {
  final List<String> _pinDigits = [];
  String? _errorMessage;
  static const int _pinLength = 6;

  /// Format angka ke format Rupiah
  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  /// Menambahkan digit ke PIN
  void _addDigit(String digit) {
    if (_pinDigits.length < _pinLength) {
      setState(() {
        _pinDigits.add(digit);
        _errorMessage = null;
      });

      // Auto-submit saat PIN sudah lengkap 6 digit
      if (_pinDigits.length == _pinLength) {
        _submitPin();
      }
    }
  }

  /// Menghapus digit terakhir
  void _removeDigit() {
    if (_pinDigits.isNotEmpty) {
      setState(() {
        _pinDigits.removeLast();
        _errorMessage = null;
      });
    }
  }

  /// Submit PIN — return PIN string ke caller
  void _submitPin() {
    if (_pinDigits.length == _pinLength) {
      final pin = _pinDigits.join();
      Navigator.of(context).pop(pin); // Return PIN ke caller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================== HANDLE BAR ====================
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // ==================== HEADER ====================
            const Icon(Icons.lock, color: Color(0xFF1A237E), size: 36),
            const SizedBox(height: 12),
            const Text(
              'Masukkan PIN E-Wallet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Pembayaran: Rp ${_formatCurrency(widget.totalAmount)}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 24),

            // ==================== PIN DOTS ====================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                final isFilled = index < _pinDigits.length;
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? const Color(0xFF1A237E)
                        : Colors.transparent,
                    border: Border.all(
                      color: isFilled
                          ? const Color(0xFF1A237E)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            // ==================== ERROR MESSAGE ====================
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            const SizedBox(height: 24),

            // ==================== NUMPAD ====================
            _buildNumPad(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Numpad custom untuk input PIN
  Widget _buildNumPad() {
    return Column(
      children: [
        // Baris 1: 1, 2, 3
        _buildNumRow(['1', '2', '3']),
        // Baris 2: 4, 5, 6
        _buildNumRow(['4', '5', '6']),
        // Baris 3: 7, 8, 9
        _buildNumRow(['7', '8', '9']),
        // Baris 4: kosong, 0, hapus
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Tombol cancel
            _NumPadButton(
              onTap: () => Navigator.of(context).pop(null), // Cancel tanpa return PIN
              child: const Text('Batal', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            ),
            // Tombol 0
            _NumPadButton(
              onTap: () => _addDigit('0'),
              child: const Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            // Tombol hapus
            _NumPadButton(
              onTap: _removeDigit,
              child: const Icon(Icons.backspace_outlined, color: Color(0xFF1A237E)),
            ),
          ],
        ),
      ],
    );
  }

  /// Satu baris numpad dengan 3 tombol
  Widget _buildNumRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) {
        return _NumPadButton(
          onTap: () => _addDigit(digit),
          child: Text(digit, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }
}

/// Widget tombol numpad individual
class _NumPadButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _NumPadButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () {
        HapticFeedback.lightImpact(); // Feedback haptic saat tekan
        onTap();
      },
      child: Container(
        width: 72,
        height: 56,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
