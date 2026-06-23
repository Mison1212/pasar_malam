import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pasar_malam/features/wallet/data/models/wallet_model.dart';
import 'package:pasar_malam/features/wallet/data/models/wallet_transaction_model.dart';



class WalletFirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  CollectionReference get _walletsRef => _firestore.collection('wallets');

  
  CollectionReference get _transactionsRef =>
      _firestore.collection('wallet_transactions');

  

  
  
  
  Future<WalletModel?> getWallet(String userId) async {
    try {
      final doc = await _walletsRef.doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return WalletModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('[WALLET DS] Error getWallet: $e');
      rethrow;
    }
  }

  
  
  Future<void> createWallet(String userId) async {
    try {
      final newWallet = WalletModel.newWallet(userId);

      await _walletsRef.doc(userId).set(newWallet.toFirestore());

      debugPrint('[WALLET DS] Wallet baru dibuat untuk user: $userId');
    } catch (e) {
      debugPrint('[WALLET DS] Error createWallet: $e');
      rethrow;
    }
  }

  
  Future<void> savePinHash(String userId, String pinHash) async {
    try {
      await _walletsRef.doc(userId).update({
        'pin_hash': pinHash,
        'is_pin_set': true,
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint('[WALLET DS] PIN berhasil disimpan untuk user: $userId');
    } catch (e) {
      debugPrint('[WALLET DS] Error savePinHash: $e');
      rethrow;
    }
  }

  
  Future<String?> getPinHash(String userId) async {
    try {
      final doc = await _walletsRef.doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>?;

      return data?['pin_hash'] as String?;
    } catch (e) {
      debugPrint('[WALLET DS] Error getPinHash: $e');
      rethrow;
    }
  }

  
  Future<void> updateBalance(String userId, double newBalance) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _walletsRef.doc(userId);

        transaction.update(docRef, {
          'balance': newBalance,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });

      debugPrint('[WALLET DS] Balance updated: $newBalance untuk user: $userId');
    } catch (e) {
      debugPrint('[WALLET DS] Error updateBalance: $e');
      rethrow;
    }
  }

  

  
  
  
  
  Future<String> addTransaction(WalletTransactionModel transaction) async {
    try {
      final docRef = await _transactionsRef.add(transaction.toFirestore());

      debugPrint('[WALLET DS] Transaksi tercatat: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      debugPrint('[WALLET DS] Error addTransaction: $e');
      rethrow;
    }
  }

  
  
  
  
  
  
  
  
  
  
  
  Future<String> addPaymentTransaction({
    required String userId,
    required num amount,
    required String orderId,
  }) async {
    try {
      final docRef = await _transactionsRef.add({
        'wallet_id': userId,
        'type': 'payment',
        'amount': amount,
        'description': 'Pembayaran pesanan',
        'status': 'success',
        'order_id': orderId,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('[WALLET DS] Transaksi pembayaran tercatat: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      debugPrint('[WALLET DS] Error addPaymentTransaction: $e');
      rethrow;
    }
  }

  
  
  
  Future<String> payOrderWithWallet({
    required String userId,
    required num amount,
    required String orderId,
  }) async {
    try {
      final walletRef = _walletsRef.doc(userId);
      final transactionRef = _transactionsRef.doc();

      await _firestore.runTransaction((transaction) async {
        final walletSnapshot = await transaction.get(walletRef);

        if (!walletSnapshot.exists) {
          throw Exception('Wallet tidak ditemukan');
        }

        final walletData = walletSnapshot.data() as Map<String, dynamic>;
        final currentBalanceRaw = walletData['balance'] ?? 0;

        final num currentBalance = currentBalanceRaw is num
            ? currentBalanceRaw
            : num.tryParse(currentBalanceRaw.toString()) ?? 0;

        if (currentBalance < amount) {
          throw Exception('Saldo tidak cukup');
        }

        final num newBalance = currentBalance - amount;

        
        transaction.update(walletRef, {
          'balance': newBalance,
          'updated_at': FieldValue.serverTimestamp(),
        });

        
        transaction.set(transactionRef, {
          'wallet_id': userId,
          'type': 'payment',
          'amount': amount,
          'description': 'Pembayaran pesanan',
          'status': 'success',
          'order_id': orderId,
          'created_at': FieldValue.serverTimestamp(),
        });
      });

      debugPrint('[WALLET DS] Pembayaran berhasil untuk order: $orderId');

      return transactionRef.id;
    } catch (e) {
      debugPrint('[WALLET DS] Error payOrderWithWallet: $e');
      rethrow;
    }
  }

  
  
  Future<List<WalletTransactionModel>> getTransactions(String userId) async {
    try {
      final querySnapshot = await _transactionsRef
          .where('wallet_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => WalletTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('[WALLET DS] Error getTransactions: $e');
      rethrow;
    }
  }
}