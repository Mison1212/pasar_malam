import 'package:pasar_malam/features/wallet/domain/entities/wallet_entity.dart';
import 'package:pasar_malam/features/wallet/domain/entities/wallet_transaction_entity.dart';

/// Kontrak repository untuk fitur E-Wallet.
/// Mendefinisikan semua operasi yang bisa dilakukan pada wallet.
/// Implementasi konkret ada di Data Layer (wallet_repository_impl.dart).
abstract class WalletRepository {
  /// Mengambil data wallet user berdasarkan userId.
  /// Jika wallet belum ada, akan dibuat otomatis dengan saldo 0.
  Future<WalletEntity> getWallet(String userId);

  /// Setup PIN 6 digit untuk wallet user.
  /// PIN akan di-hash menggunakan SHA-256 sebelum disimpan.
  Future<void> setupPin(String userId, String pin);

  /// Validasi PIN yang dimasukkan user.
  /// Membandingkan hash dari input PIN dengan hash yang tersimpan.
  /// Return true jika PIN cocok.
  Future<bool> validatePin(String userId, String pin);

  /// Top up saldo wallet.
  /// Menambahkan [amount] ke balance dan mencatat transaksi.
  Future<void> topUp(String userId, double amount);

  /// Debit (potong) saldo wallet untuk pembayaran.
  /// Validasi: PIN harus benar DAN saldo harus cukup.
  /// [referenceId] = ID pesanan yang dibayar.
  /// Throws Exception jika PIN salah atau saldo tidak cukup.
  Future<void> debit(String userId, double amount, String pin, {String? referenceId});

  /// Mengambil riwayat transaksi wallet, diurutkan dari terbaru.
  Future<List<WalletTransactionEntity>> getTransactions(String userId);
}
