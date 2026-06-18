import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasar_malam/features/wallet/domain/entities/wallet_transaction_entity.dart';

/// Model Firestore untuk transaksi wallet.
/// Menyimpan setiap operasi topup/debit sebagai dokumen terpisah.
class WalletTransactionModel extends WalletTransactionEntity {
  const WalletTransactionModel({
    super.id,
    required super.walletId,
    required super.amount,
    required super.type,
    required super.status,
    super.referenceId,
    required super.description,
    super.createdAt,
  });

  /// Membuat WalletTransactionModel dari document snapshot Firestore.
  factory WalletTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return WalletTransactionModel(
      id: doc.id,
      walletId: data['wallet_id'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] as String? ?? 'topup',
      status: data['status'] as String? ?? 'success',
      referenceId: data['reference_id'] as String?,
      description: data['description'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Konversi ke Map untuk disimpan ke Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'wallet_id': walletId,
      'amount': amount,
      'type': type,
      'status': status,
      if (referenceId != null) 'reference_id': referenceId,
      'description': description,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
