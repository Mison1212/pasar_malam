import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/cart/presentation/providers/cart_provider.dart';
import 'package:pasar_malam/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:pasar_malam/features/orders/presentation/providers/order_provider.dart';
import 'package:pasar_malam/features/wallet/presentation/widgets/pin_bottom_sheet.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/orders/presentation/pages/order_success_page.dart';









class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  
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
    final cart = context.watch<CartProvider>();
    final items = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final it = items[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      it.product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(it.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Jumlah: ${it.quantity}'),
                  trailing: Text(
                    'Rp ${_formatCurrency(it.product.price * it.quantity)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                );
              },
            ),
          ),

          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  Consumer<WalletProvider>(
                    builder: (ctx, wallet, _) => Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, color: Color(0xFF1A237E), size: 20),
                          const SizedBox(width: 8),
                          const Text('Saldo E-Wallet: ', style: TextStyle(fontSize: 13)),
                          Text(
                            'Rp ${wallet.formattedBalance}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(fontSize: 16)),
                      Text(
                        'Rp ${_formatCurrency(cart.totalPrice)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  
                  ElevatedButton.icon(
                    onPressed: () {
                      _handlePayment(context, cart);
                    },
                    icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                    label: const Text(
                      'Bayar via Saldo Internal',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ElevatedButton.icon(
                    onPressed: () => _handleExternalPayment(context, cart),
                    icon: const Icon(Icons.open_in_new, color: Colors.white),
                    label: const Text(
                      'Bayar via Aplikasi E-Wallet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  Future<void> _handlePayment(BuildContext context, CartProvider cart) async {
    final userId = context.read<AuthProvider>().firebaseUser?.uid;
    if (userId == null) {
      _showError(context, 'User tidak ditemukan. Silakan login ulang.');
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    final orderProvider = context.read<OrderProvider>();
    final totalAmount = cart.totalPrice;

    
    if (!walletProvider.isPinSet) {
      final shouldSetup = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('PIN Belum Di-setup'),
          content: const Text(
            'Anda perlu membuat PIN E-Wallet terlebih dahulu untuk melakukan pembayaran.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
              child: const Text('Setup PIN', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (shouldSetup == true && context.mounted) {
        Navigator.pushNamed(context, AppRouter.setupPin);
      }
      return;
    }

    
    if (walletProvider.balance < totalAmount) {
      if (!context.mounted) return;
      _showInsufficientBalance(context, totalAmount, walletProvider.balance);
      return;
    }

    
    if (!context.mounted) return;
    final pin = await PinBottomSheet.show(context, totalAmount: totalAmount);

    
    if (pin == null) return;

    
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF1A237E)),
                SizedBox(height: 16),
                Text('Memproses pembayaran...'),
              ],
            ),
          ),
        ),
      ),
    );

    
    final debitSuccess = await walletProvider.debit(
      userId,
      totalAmount,
      pin,
    );

    
    if (context.mounted) Navigator.of(context).pop();

    if (!debitSuccess) {
      if (!context.mounted) return;

      
      if (walletProvider.isPinError) {
        _showError(context, 'PIN yang Anda masukkan salah. Silakan coba lagi.');
      } else if (walletProvider.isInsufficientBalance) {
        _showInsufficientBalance(context, totalAmount, walletProvider.balance);
      } else {
        _showError(context, walletProvider.errorMessage ?? 'Pembayaran gagal');
      }
      return;
    }

    
    final cartItems = cart.items.values
        .map((item) => {
              'product_id': item.product.id,
              'product_name': item.product.name,
              'price': item.product.price,
              'quantity': item.quantity,
              'image_url': item.product.imageUrl,
            })
        .toList();

    final orderId = await orderProvider.createOrder(
      userId: userId,
      items: cartItems,
      totalAmount: totalAmount,
    );

    if (orderId == null) {
      if (context.mounted) {
        _showError(context, 'Pembayaran berhasil, tapi gagal membuat pesanan. Hubungi customer service.');
      }
      return;
    }

    
    cart.clearCart(userId: userId);

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => OrderSuccessPage(
            orderId: orderId,
            totalAmount: totalAmount,
          ),
        ),
        (route) => false,
      );
    }
  }

  
  void _showInsufficientBalance(
      BuildContext context, double totalAmount, double currentBalance) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Saldo Tidak Cukup'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Belanja: Rp ${_formatCurrency(totalAmount)}'),
            Text('Saldo Anda: Rp ${_formatCurrency(currentBalance)}'),
            const SizedBox(height: 8),
            Text(
              'Kekurangan: Rp ${_formatCurrency(totalAmount - currentBalance)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushNamed(context, AppRouter.topUp);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Top Up Sekarang', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  
  Future<void> _handleExternalPayment(BuildContext context, CartProvider cart) async {
    final userId = context.read<AuthProvider>().firebaseUser?.uid;
    if (userId == null) {
      _showError(context, 'User tidak ditemukan. Silakan login ulang.');
      return;
    }
    
    final orderProvider = context.read<OrderProvider>();
    final totalAmount = cart.totalPrice;

    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF1A237E)),
                SizedBox(height: 16),
                Text('Menyiapkan pesanan...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    
    final cartItems = cart.items.values
        .map((item) => {
              'product_id': item.product.id,
              'product_name': item.product.name,
              'price': item.product.price,
              'quantity': item.quantity,
              'image_url': item.product.imageUrl,
            })
        .toList();

    final orderId = await orderProvider.createOrder(
      userId: userId,
      items: cartItems,
      totalAmount: totalAmount,
    );

    
    if (context.mounted) Navigator.of(context).pop();

    if (orderId == null) {
      if (context.mounted) _showError(context, 'Gagal membuat pesanan untuk E-Wallet');
      return;
    }

    
    cart.clearCart(userId: userId);

    
    final Uri ewalletUrl = Uri.parse(
      "myewallet://pay?order_id=$orderId&amount=$totalAmount&callback_url=mymarketplace://payment_result"
    );

    
    try {
      final launched = await launchUrl(ewalletUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (context.mounted) {
          _showError(context, 'Gagal membuka aplikasi E-Wallet. Pastikan aplikasi terinstall di HP/Emulator ini.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Gagal membuka aplikasi E-Wallet. Pastikan aplikasi terinstall di HP/Emulator ini.');
      }
    }
  }

  
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
