import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasar_malam/features/wallet/domain/entities/wallet_entity.dart';



class WalletModel extends WalletEntity {
  final String? pinHash; 

  const WalletModel({
    required super.userId,
    required super.balance,
    required super.isPinSet,
    super.createdAt,
    super.updatedAt,
    this.pinHash,
  });

  
  
  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return WalletModel(
      userId: doc.id,
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      isPinSet: data['is_pin_set'] as bool? ?? false,
      pinHash: data['pin_hash'] as String?,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  
  Map<String, dynamic> toFirestore() {
    return {
      'balance': balance,
      'is_pin_set': isPinSet,
      if (pinHash != null) 'pin_hash': pinHash,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  
  factory WalletModel.newWallet(String userId) {
    return WalletModel(
      userId: userId,
      balance: 0.0,
      isPinSet: false,
      pinHash: null,
    );
  }
}
