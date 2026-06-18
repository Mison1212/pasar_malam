import 'package:equatable/equatable.dart';

/// Entity yang merepresentasikan satu transaksi wallet (topup/debit).
/// Digunakan untuk histori transaksi dan audit trail.
class WalletTransactionEntity extends Equatable {
  final String? id;
  final String walletId;       // firebase_uid pemilik wallet
  final double amount;
  final String type;           // "topup" atau "debit"
  final String status;         // "success" atau "failed"
  final String? referenceId;   // ID pesanan (jika debit untuk pembayaran)
  final String description;
  final DateTime? createdAt;

  const WalletTransactionEntity({
    this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    required this.status,
    this.referenceId,
    required this.description,
    this.createdAt,
  });

  /// Cek apakah transaksi ini adalah top up
  bool get isTopUp => type == 'topup';

  /// Cek apakah transaksi ini adalah debit (pembayaran)
  bool get isDebit => type == 'debit';

  @override
  List<Object?> get props => [
        id, walletId, amount, type, status, referenceId, description, createdAt,
      ];
}
