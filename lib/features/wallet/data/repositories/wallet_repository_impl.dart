import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:pasar_malam/features/wallet/data/datasources/wallet_firestore_datasource.dart';
import 'package:pasar_malam/features/wallet/data/models/wallet_model.dart';
import 'package:pasar_malam/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:pasar_malam/features/wallet/domain/entities/wallet_entity.dart';
import 'package:pasar_malam/features/wallet/domain/entities/wallet_transaction_entity.dart';
import 'package:pasar_malam/features/wallet/domain/repositories/wallet_repository.dart';






class WalletRepositoryImpl implements WalletRepository {
  final WalletFirestoreDatasource _datasource;

  WalletRepositoryImpl({WalletFirestoreDatasource? datasource})
      : _datasource = datasource ?? WalletFirestoreDatasource();

  

  
  
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  

  
  
  @override
  Future<WalletEntity> getWallet(String userId) async {
    try {
      WalletModel? wallet = await _datasource.getWallet(userId);

      
      if (wallet == null) {
        await _datasource.createWallet(userId);
        wallet = await _datasource.getWallet(userId);
      }

      return wallet ?? WalletModel.newWallet(userId);
    } catch (e) {
      debugPrint('[WALLET REPO] Error getWallet: $e');
      throw Exception('Gagal mengambil data wallet: $e');
    }
  }

  

  
  
  @override
  Future<void> setupPin(String userId, String pin) async {
    try {
      
      if (pin.length != 6 || int.tryParse(pin) == null) {
        throw Exception('PIN harus 6 digit angka');
      }

      final pinHash = _hashPin(pin);
      await _datasource.savePinHash(userId, pinHash);
      debugPrint('[WALLET REPO] PIN berhasil di-setup untuk user: $userId');
    } catch (e) {
      debugPrint('[WALLET REPO] Error setupPin: $e');
      rethrow;
    }
  }

  
  
  @override
  Future<bool> validatePin(String userId, String pin) async {
    try {
      final storedHash = await _datasource.getPinHash(userId);
      if (storedHash == null) {
        throw Exception('PIN belum di-setup');
      }

      final inputHash = _hashPin(pin);
      return storedHash == inputHash;
    } catch (e) {
      debugPrint('[WALLET REPO] Error validatePin: $e');
      rethrow;
    }
  }

  

  
  
  @override
  Future<void> topUp(String userId, double amount) async {
    try {
      
      if (amount <= 0) {
        throw Exception('Nominal top up harus lebih dari 0');
      }

      
      final wallet = await _datasource.getWallet(userId);
      if (wallet == null) {
        throw Exception('Wallet tidak ditemukan');
      }

      
      final newBalance = wallet.balance + amount;

      
      await _datasource.updateBalance(userId, newBalance);

      
      final transaction = WalletTransactionModel(
        walletId: userId,
        amount: amount,
        type: 'topup',
        status: 'success',
        description: 'Top Up Saldo',
      );
      await _datasource.addTransaction(transaction);

      debugPrint('[WALLET REPO] Top up berhasil: +Rp $amount');
    } catch (e) {
      debugPrint('[WALLET REPO] Error topUp: $e');
      rethrow;
    }
  }

  

  
  
  
  @override
  Future<void> debit(String userId, double amount, String pin,
      {String? referenceId}) async {
    try {
      
      if (amount <= 0) {
        throw Exception('Nominal pembayaran harus lebih dari 0');
      }

      
      final isPinValid = await validatePin(userId, pin);
      if (!isPinValid) {
        throw Exception('PIN_SALAH'); 
      }

      
      final wallet = await _datasource.getWallet(userId);
      if (wallet == null) {
        throw Exception('Wallet tidak ditemukan');
      }

      if (wallet.balance < amount) {
        throw Exception('SALDO_KURANG'); 
      }

      
      final newBalance = wallet.balance - amount;
      await _datasource.updateBalance(userId, newBalance);

      
      final transaction = WalletTransactionModel(
        walletId: userId,
        amount: amount,
        type: 'debit',
        status: 'success',
        referenceId: referenceId,
        description: referenceId != null
            ? 'Pembayaran Pesanan #$referenceId'
            : 'Pembayaran',
      );
      await _datasource.addTransaction(transaction);

      debugPrint('[WALLET REPO] Debit berhasil: -Rp $amount');
    } catch (e) {
      debugPrint('[WALLET REPO] Error debit: $e');
      rethrow;
    }
  }

  

  
  @override
  Future<List<WalletTransactionEntity>> getTransactions(String userId) async {
    try {
      return await _datasource.getTransactions(userId);
    } catch (e) {
      debugPrint('[WALLET REPO] Error getTransactions: $e');
      throw Exception('Gagal mengambil riwayat transaksi: $e');
    }
  }
}
