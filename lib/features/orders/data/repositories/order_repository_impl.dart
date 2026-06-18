import 'package:flutter/foundation.dart';
import 'package:pasar_malam/features/orders/data/datasources/order_firestore_datasource.dart';
import 'package:pasar_malam/features/orders/data/models/order_model.dart';
import 'package:pasar_malam/features/orders/domain/entities/order_entity.dart';
import 'package:pasar_malam/features/orders/domain/repositories/order_repository.dart';

/// Implementasi konkret dari OrderRepository.
/// Mengorkestrasi panggilan ke datasource Firestore.
class OrderRepositoryImpl implements OrderRepository {
  final OrderFirestoreDatasource _datasource;

  OrderRepositoryImpl({OrderFirestoreDatasource? datasource})
      : _datasource = datasource ?? OrderFirestoreDatasource();

  /// Membuat pesanan baru. Konversi entity ke model sebelum simpan.
  @override
  Future<String> createOrder(OrderEntity order) async {
    try {
      final orderModel = OrderModel(
        userId: order.userId,
        items: order.items,
        totalAmount: order.totalAmount,
        status: order.status,
        paymentMethod: order.paymentMethod,
      );
      return await _datasource.createOrder(orderModel);
    } catch (e) {
      debugPrint('[ORDER REPO] Error createOrder: $e');
      throw Exception('Gagal membuat pesanan: $e');
    }
  }

  /// Update status pesanan.
  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _datasource.updateOrderStatus(orderId, status);
    } catch (e) {
      debugPrint('[ORDER REPO] Error updateOrderStatus: $e');
      throw Exception('Gagal mengubah status pesanan: $e');
    }
  }

  /// Mengambil daftar pesanan user.
  @override
  Future<List<OrderEntity>> getUserOrders(String userId) async {
    try {
      return await _datasource.getUserOrders(userId);
    } catch (e) {
      debugPrint('[ORDER REPO] Error getUserOrders: $e');
      throw Exception('Gagal mengambil daftar pesanan: $e');
    }
  }
}
