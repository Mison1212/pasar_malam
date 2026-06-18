import 'package:pasar_malam/features/orders/domain/entities/order_entity.dart';

/// Kontrak repository untuk fitur Orders.
/// Mendefinisikan operasi CRUD pesanan.
abstract class OrderRepository {
  /// Membuat pesanan baru dan return ID pesanan.
  Future<String> createOrder(OrderEntity order);

  /// Update status pesanan (misalnya dari pending_payment ke paid).
  Future<void> updateOrderStatus(String orderId, String status);

  /// Mengambil daftar pesanan milik user tertentu.
  Future<List<OrderEntity>> getUserOrders(String userId);
}
