import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/wallet/presentation/providers/wallet_provider.dart';



class SetupPinPage extends StatefulWidget {
  const SetupPinPage({super.key});

  @override
  State<SetupPinPage> createState() => _SetupPinPageState();
}

class _SetupPinPageState extends State<SetupPinPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final FocusNode _confirmFocus = FocusNode();
  bool _isProcessing = false;
  bool _obscurePin = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  
  Future<void> _savePin() async {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    
    if (pin.length != 6) {
      _showSnackBar('PIN harus 6 digit', isError: true);
      return;
    }

    if (pin != confirmPin) {
      _showSnackBar('PIN dan Konfirmasi PIN tidak cocok', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    final userId = context.read<AuthProvider>().firebaseUser?.uid;
    if (userId == null) {
      _showSnackBar('User tidak ditemukan', isError: true);
      setState(() => _isProcessing = false);
      return;
    }

    final success = await context.read<WalletProvider>().setupPin(userId, pin);

    setState(() => _isProcessing = false);

    if (success && mounted) {
      _showSnackBar('PIN berhasil disimpan!');
      Navigator.of(context).pop(); 
    } else if (mounted) {
      _showSnackBar(
        context.read<WalletProvider>().errorMessage ?? 'Gagal menyimpan PIN',
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          wallet.isPinSet ? 'Ubah PIN' : 'Setup PIN',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, size: 48, color: Color(0xFF1A237E)),
                  const SizedBox(height: 12),
                  Text(
                    wallet.isPinSet
                        ? 'Ubah PIN E-Wallet Anda'
                        : 'Buat PIN untuk mengamankan transaksi',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PIN terdiri dari 6 digit angka dan digunakan setiap kali melakukan pembayaran.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            
            const Text('PIN Baru', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: _obscurePin,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (val) {
                if (val.length == 6) {
                  _confirmFocus.requestFocus(); 
                }
              },
              decoration: InputDecoration(
                hintText: 'Masukkan 6 digit PIN',
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
              ),
            ),

            const SizedBox(height: 20),

            
            const Text('Konfirmasi PIN', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPinController,
              focusNode: _confirmFocus,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: _obscureConfirm,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Ulangi 6 digit PIN',
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),

            const SizedBox(height: 32),

            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _savePin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Simpan PIN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
