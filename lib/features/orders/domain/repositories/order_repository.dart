import 'package:pasar_malam/features/orders/domain/entities/order_entity.dart';



abstract class OrderRepository {
  
  Future<String> createOrder(OrderEntity order);

  
  Future<void> updateOrderStatus(String orderId, String status);

  
  Future<List<OrderEntity>> getUserOrders(String userId);
}
