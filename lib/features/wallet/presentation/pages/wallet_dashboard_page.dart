import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:pasar_malam/core/routes/app_router.dart';

/// Halaman Dashboard E-Wallet.
/// Menampilkan saldo, tombol Top Up, dan riwayat transaksi.
class WalletDashboardPage extends StatefulWidget {
  const WalletDashboardPage({super.key});

  @override
  State<WalletDashboardPage> createState() => _WalletDashboardPageState();
}

class _WalletDashboardPageState extends State<WalletDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load wallet data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().firebaseUser?.uid;
      if (userId != null) {
        context.read<WalletProvider>().loadWallet(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final userId = context.read<AuthProvider>().firebaseUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('E-Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: wallet.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : RefreshIndicator(
              onRefresh: () async {
                if (userId != null) {
                  await wallet.loadWallet(userId);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ==================== CARD SALDO ====================
                    _buildBalanceCard(context, wallet),

                    // ==================== MENU AKSI ====================
                    _buildActionButtons(context, wallet),

                    // ==================== RIWAYAT TRANSAKSI ====================
                    _buildTransactionHistory(wallet),
                  ],
                ),
              ),
            ),
    );
  }

  /// Card gradient yang menampilkan saldo wallet.
  Widget _buildBalanceCard(BuildContext context, WalletProvider wallet) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Saldo Anda',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  wallet.isPinSet ? '🔒 PIN Aktif' : '⚠️ Belum Setup PIN',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Rp ${wallet.formattedBalance}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fashion Papua E-Wallet',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Tombol aksi: Top Up dan Setup PIN.
  Widget _buildActionButtons(BuildContext context, WalletProvider wallet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Tombol Top Up
          Expanded(
            child: _ActionButton(
              icon: Icons.add_circle_outline,
              label: 'Top Up',
              color: const Color(0xFF2E7D32),
              onTap: () => Navigator.pushNamed(context, AppRouter.topUp),
            ),
          ),
          const SizedBox(width: 12),
          // Tombol Setup / Ubah PIN
          Expanded(
            child: _ActionButton(
              icon: wallet.isPinSet ? Icons.lock_outline : Icons.lock_open,
              label: wallet.isPinSet ? 'Ubah PIN' : 'Setup PIN',
              color: const Color(0xFFE65100),
              onTap: () => Navigator.pushNamed(context, AppRouter.setupPin),
            ),
          ),
        ],
      ),
    );
  }

  /// Riwayat transaksi wallet.
  Widget _buildTransactionHistory(WalletProvider wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Riwayat Transaksi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
          ),
        ),
        if (wallet.transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: wallet.transactions.length,
            itemBuilder: (ctx, i) {
              final tx = wallet.transactions[i];
              final isTopUp = tx.isTopUp;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isTopUp
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    child: Icon(
                      isTopUp ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isTopUp ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                  title: Text(
                    tx.description,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    tx.createdAt != null
                        ? '${tx.createdAt!.day}/${tx.createdAt!.month}/${tx.createdAt!.year} ${tx.createdAt!.hour}:${tx.createdAt!.minute.toString().padLeft(2, '0')}'
                        : '-',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Text(
                    '${isTopUp ? '+' : '-'}Rp ${tx.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isTopUp ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Widget reusable untuk tombol aksi di dashboard wallet.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
