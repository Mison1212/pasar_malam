import 'package:equatable/equatable.dart';



class WalletTransactionEntity extends Equatable {
  final String? id;
  final String walletId;       
  final double amount;
  final String type;           
  final String status;         
  final String? referenceId;   
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

  
  bool get isTopUp => type == 'topup';

  
  bool get isDebit => type == 'debit';

  @override
  List<Object?> get props => [
        id, walletId, amount, type, status, referenceId, description, createdAt,
      ];
}
