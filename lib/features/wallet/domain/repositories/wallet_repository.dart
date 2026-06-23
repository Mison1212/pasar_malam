import 'package:pasar_malam/features/wallet/domain/entities/wallet_entity.dart';
import 'package:pasar_malam/features/wallet/domain/entities/wallet_transaction_entity.dart';




abstract class WalletRepository {
  
  
  Future<WalletEntity> getWallet(String userId);

  
  
  Future<void> setupPin(String userId, String pin);

  
  
  
  Future<bool> validatePin(String userId, String pin);

  
  
  Future<void> topUp(String userId, double amount);

  
  
  
  
  Future<void> debit(String userId, double amount, String pin, {String? referenceId});

  
  Future<List<WalletTransactionEntity>> getTransactions(String userId);
}
