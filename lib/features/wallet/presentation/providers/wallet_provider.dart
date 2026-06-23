import 'package:flutter/material.dart';
import 'package:pasar_malam/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:pasar_malam/features/wallet/domain/entities/wallet_entity.dart';
import 'package:pasar_malam/features/wallet/domain/entities/wallet_transaction_entity.dart';
import 'package:pasar_malam/features/wallet/domain/repositories/wallet_repository.dart';



class WalletProvider extends ChangeNotifier {
  final WalletRepository _repository;

  WalletProvider({WalletRepository? repository})
      : _repository = repository ?? WalletRepositoryImpl();

  

  WalletEntity? _wallet;
  List<WalletTransactionEntity> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  

  WalletEntity? get wallet => _wallet;
  double get balance => _wallet?.balance ?? 0.0;
  bool get isPinSet => _wallet?.isPinSet ?? false;
  List<WalletTransactionEntity> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  
  String get formattedBalance {
    return balance
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  

  
  
  Future<void> loadWallet(String userId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _wallet = await _repository.getWallet(userId);
      _transactions = await _repository.getTransactions(userId);

      debugPrint('[WALLET PROVIDER] Wallet loaded: balance=${_wallet?.balance}');
    } catch (e) {
      _errorMessage = 'Gagal memuat data wallet';
      debugPrint('[WALLET PROVIDER] Error loadWallet: $e');
    } finally {
      _setLoading(false);
    }
  }

  
  
  Future<bool> setupPin(String userId, String pin) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _repository.setupPin(userId, pin);

      
      _wallet = await _repository.getWallet(userId);

      debugPrint('[WALLET PROVIDER] PIN berhasil di-setup');
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('[WALLET PROVIDER] Error setupPin: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  
  
  Future<bool> validatePin(String userId, String pin) async {
    try {
      return await _repository.validatePin(userId, pin);
    } catch (e) {
      debugPrint('[WALLET PROVIDER] Error validatePin: $e');
      return false;
    }
  }

  
  
  Future<bool> topUp(String userId, double amount) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _repository.topUp(userId, amount);

      
      _wallet = await _repository.getWallet(userId);
      _transactions = await _repository.getTransactions(userId);

      debugPrint('[WALLET PROVIDER] Top up berhasil: +Rp $amount');
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('[WALLET PROVIDER] Error topUp: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  
  
  
  Future<bool> debit(
      String userId, double amount, String pin, {String? referenceId}) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _repository.debit(userId, amount, pin, referenceId: referenceId);

      
      _wallet = await _repository.getWallet(userId);
      _transactions = await _repository.getTransactions(userId);

      debugPrint('[WALLET PROVIDER] Debit berhasil: -Rp $amount');
      return true;
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('PIN_SALAH')) {
        _errorMessage = 'PIN yang Anda masukkan salah';
      } else if (errorMsg.contains('SALDO_KURANG')) {
        _errorMessage = 'Saldo tidak mencukupi';
      } else {
        _errorMessage = 'Gagal melakukan pembayaran';
      }
      debugPrint('[WALLET PROVIDER] Error debit: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  
  
  bool get isInsufficientBalance =>
      _errorMessage == 'Saldo tidak mencukupi';

  
  bool get isPinError =>
      _errorMessage == 'PIN yang Anda masukkan salah';

  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
