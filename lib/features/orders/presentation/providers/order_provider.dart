import 'package:flutter/material.dart';
import 'package:pasar_malam/features/orders/data/repositories/order_repository_impl.dart';
import 'package:pasar_malam/features/orders/domain/entities/order_entity.dart';
import 'package:pasar_malam/features/orders/domain/repositories/order_repository.dart';

/// State management untuk fitur Orders.
/// Mengelola pembuatan dan tracking pesanan.
class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;

  OrderProvider({OrderRepository? repository})
      : _repository = repository ?? OrderRepositoryImpl();

  // ==================== STATE ====================

  List<OrderEntity> _orders = [];
  String? _lastOrderId;
  bool _isLoading = false;
  String? _errorMessage;

  // ==================== GETTERS ====================

  List<OrderEntity> get orders => _orders;
  String? get lastOrderId => _lastOrderId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==================== METHODS ====================

  /// Membuat pesanan baru dengan status 'paid' (sudah dibayar via e-wallet).
  /// Return order ID jika berhasil, null jika gagal.
  Future<String?> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final order = OrderEntity(
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        status: 'paid', // Langsung PAID karena sudah di-debit dari wallet
        paymentMethod: 'ewallet',
      );

      _lastOrderId = await _repository.createOrder(order);
      debugPrint('[ORDER PROVIDER] Pesanan dibuat: $_lastOrderId');
      return _lastOrderId;
    } catch (e) {
      _errorMessage = 'Gagal membuat pesanan';
      debugPrint('[ORDER PROVIDER] Error createOrder: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load daftar pesanan milik user.
  Future<void> loadUserOrders(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _orders = await _repository.getUserOrders(userId);
      debugPrint('[ORDER PROVIDER] Loaded ${_orders.length} pesanan');
    } catch (e) {
      _errorMessage = 'Gagal memuat pesanan';
      debugPrint('[ORDER PROVIDER] Error loadUserOrders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
