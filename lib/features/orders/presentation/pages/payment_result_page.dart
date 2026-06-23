import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';

class PaymentResultPage extends StatelessWidget {
  final String orderId;
  final String status;

  const PaymentResultPage({
    super.key,
    required this.orderId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == 'success';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pembayaran'),
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 100,
                ),
                const SizedBox(height: 24),
                Text(
                  isSuccess ? 'Pembayaran Berhasil!' : 'Pembayaran Gagal',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Order ID: $orderId',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.dashboard,
                    (route) => false,
                  );
                  },
                  child: const Text('Kembali ke Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
