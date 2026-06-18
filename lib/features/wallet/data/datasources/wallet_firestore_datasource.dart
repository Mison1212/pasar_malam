import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pasar_malam/features/wallet/data/models/wallet_model.dart';
import 'package:pasar_malam/features/wallet/data/models/wallet_transaction_model.dart';

/// Data source yang berinteraksi langsung dengan Cloud Firestore.
/// Menangani CRUD pada koleksi 'wallets' dan 'wallet_transactions'.
class WalletFirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Referensi ke koleksi 'wallets' di Firestore.
  CollectionReference get _walletsRef => _firestore.collection('wallets');

  /// Referensi ke koleksi 'wallet_transactions' di Firestore.
  CollectionReference get _transactionsRef =>
      _firestore.collection('wallet_transactions');

  // ==================== WALLET OPERATIONS ====================

  /// Mengambil data wallet berdasarkan userId.
  /// Document ID = firebase_uid.
  /// Return null jika wallet belum ada.
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

  /// Membuat wallet baru di Firestore untuk user pertama kali.
  /// Document ID = firebase_uid agar satu user hanya punya satu wallet.
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

  /// Menyimpan hash PIN ke dokumen wallet user.
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

  /// Mengambil hash PIN yang tersimpan untuk validasi.
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

  /// Update saldo wallet.
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

  // ==================== TRANSACTION OPERATIONS ====================

  /// Mencatat transaksi baru ke koleksi wallet_transactions.
  /// Biasanya dipakai untuk topup atau transaksi umum.
  ///
  /// Return: document ID dari transaksi yang baru dibuat.
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

  /// Mencatat transaksi pembayaran checkout ke wallet_transactions.
  /// Dipakai saat user checkout produk menggunakan saldo e-wallet.
  ///
  /// Hasil di Firestore:
  /// - wallet_id
  /// - type: payment
  /// - amount
  /// - description: Pembayaran pesanan
  /// - status: success
  /// - order_id
  /// - created_at
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

  /// Mengurangi saldo wallet dan langsung mencatat transaksi payment.
  /// Fungsi ini cocok dipakai saat checkout supaya saldo dan transaksi
  /// tercatat secara atomic dalam satu Firestore transaction.
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

        // 1. Kurangi saldo wallet
        transaction.update(walletRef, {
          'balance': newBalance,
          'updated_at': FieldValue.serverTimestamp(),
        });

        // 2. Catat transaksi pembayaran
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

  /// Mengambil riwayat transaksi wallet, diurutkan dari terbaru.
  /// Limit 50 transaksi terakhir untuk performa.
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