import 'package:flutter/foundation.dart';
import 'package:pasar_malam/features/orders/data/datasources/order_firestore_datasource.dart';
import 'package:pasar_malam/features/orders/data/models/order_model.dart';
import 'package:pasar_malam/features/orders/domain/entities/order_entity.dart';
import 'package:pasar_malam/features/orders/domain/repositories/order_repository.dart';



class OrderRepositoryImpl implements OrderRepository {
  final OrderFirestoreDatasource _datasource;

  OrderRepositoryImpl({OrderFirestoreDatasource? datasource})
      : _datasource = datasource ?? OrderFirestoreDatasource();

  
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

  
  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _datasource.updateOrderStatus(orderId, status);
    } catch (e) {
      debugPrint('[ORDER REPO] Error updateOrderStatus: $e');
      throw Exception('Gagal mengubah status pesanan: $e');
    }
  }

  
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
