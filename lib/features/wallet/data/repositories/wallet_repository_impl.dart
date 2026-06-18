import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:pasar_malam/features/wallet/data/datasources/wallet_firestore_datasource.dart';
import 'package:pasar_malam/features/wallet/data/models/wallet_model.dart';
import 'package:pasar_malam/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:pasar_malam/features/wallet/domain/entities/wallet_entity.dart';
import 'package:pasar_malam/features/wallet/domain/entities/wallet_transaction_entity.dart';
import 'package:pasar_malam/features/wallet/domain/repositories/wallet_repository.dart';

/// Implementasi konkret dari WalletRepository.
/// Mengorkestrasi panggilan ke datasource dan menerapkan bisnis logik:
/// - Hashing PIN dengan SHA-256
/// - Validasi saldo sebelum debit
/// - Pencatatan transaksi otomatis
class WalletRepositoryImpl implements WalletRepository {
  final WalletFirestoreDatasource _datasource;

  WalletRepositoryImpl({WalletFirestoreDatasource? datasource})
      : _datasource = datasource ?? WalletFirestoreDatasource();

  // ==================== HELPER: PIN HASHING ====================

  /// Hash PIN menggunakan SHA-256.
  /// PIN tidak pernah disimpan dalam bentuk plain text.
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ==================== WALLET OPERATIONS ====================

  /// Mengambil wallet user. Jika belum ada, buat wallet baru otomatis.
  /// Ini memastikan setiap user yang login selalu punya wallet.
  @override
  Future<WalletEntity> getWallet(String userId) async {
    try {
      WalletModel? wallet = await _datasource.getWallet(userId);

      // Auto-create wallet jika belum ada (first time user)
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

  // ==================== PIN OPERATIONS ====================

  /// Setup PIN baru untuk wallet user.
  /// PIN di-hash dengan SHA-256 sebelum disimpan ke Firestore.
  @override
  Future<void> setupPin(String userId, String pin) async {
    try {
      // Validasi format PIN: harus 6 digit angka
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

  /// Validasi PIN dengan membandingkan hash.
  /// Return true jika PIN yang dimasukkan cocok dengan yang tersimpan.
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

  // ==================== TOP UP ====================

  /// Top up saldo wallet.
  /// Menambahkan amount ke balance dan mencatat transaksi 'topup'.
  @override
  Future<void> topUp(String userId, double amount) async {
    try {
      // Validasi nominal
      if (amount <= 0) {
        throw Exception('Nominal top up harus lebih dari 0');
      }

      // Ambil saldo saat ini
      final wallet = await _datasource.getWallet(userId);
      if (wallet == null) {
        throw Exception('Wallet tidak ditemukan');
      }

      // Hitung saldo baru
      final newBalance = wallet.balance + amount;

      // Update saldo di Firestore (atomic transaction)
      await _datasource.updateBalance(userId, newBalance);

      // Catat transaksi top up
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

  // ==================== DEBIT (PEMBAYARAN) ====================

  /// Debit saldo wallet untuk pembayaran pesanan.
  /// Alur: Validasi PIN → Cek saldo → Potong saldo → Catat transaksi.
  /// Throws Exception dengan pesan spesifik jika gagal.
  @override
  Future<void> debit(String userId, double amount, String pin,
      {String? referenceId}) async {
    try {
      // Validasi nominal
      if (amount <= 0) {
        throw Exception('Nominal pembayaran harus lebih dari 0');
      }

      // STEP 1: Validasi PIN
      final isPinValid = await validatePin(userId, pin);
      if (!isPinValid) {
        throw Exception('PIN_SALAH'); // Error code khusus untuk PIN salah
      }

      // STEP 2: Cek saldo mencukupi
      final wallet = await _datasource.getWallet(userId);
      if (wallet == null) {
        throw Exception('Wallet tidak ditemukan');
      }

      if (wallet.balance < amount) {
        throw Exception('SALDO_KURANG'); // Error code khusus untuk saldo kurang
      }

      // STEP 3: Potong saldo (atomic transaction)
      final newBalance = wallet.balance - amount;
      await _datasource.updateBalance(userId, newBalance);

      // STEP 4: Catat transaksi debit
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

  // ==================== RIWAYAT TRANSAKSI ====================

  /// Mengambil riwayat transaksi wallet user, diurutkan terbaru.
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
