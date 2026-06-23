import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';



class OrderSuccessPage extends StatelessWidget {
  final String orderId;
  final double totalAmount;

  const OrderSuccessPage({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  
  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check, color: Color(0xFF2E7D32), size: 50),
                  ),

                  const SizedBox(height: 32),

                  
                  const Text(
                    'Pembayaran Berhasil! 🎉',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Pesanan Anda telah dibuat dan sedang diproses.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),

                  const SizedBox(height: 32),

                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(label: 'No. Pesanan', value: '#${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase()}'),
                        const Divider(height: 24),
                        _DetailRow(label: 'Total Bayar', value: 'Rp ${_formatCurrency(totalAmount)}'),
                        const Divider(height: 24),
                        const _DetailRow(label: 'Metode', value: 'E-Wallet'),
                        const Divider(height: 24),
                        const _DetailRow(label: 'Status', value: '✅ LUNAS', valueColor: Color(0xFF2E7D32)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.dashboard,
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Kembali ke Beranda',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRouter.wallet,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Lihat Saldo E-Wallet →',
                      style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor ?? const Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}
