import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pasar_malam/features/orders/data/models/order_model.dart';


class OrderFirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  CollectionReference get _ordersRef => _firestore.collection('orders');

  
  CollectionReference get _walletTransactionsRef =>
      _firestore.collection('wallet_transactions');

  
  
  
  
  
  Future<String> createOrder(OrderModel order) async {
    try {
      final orderRef = _ordersRef.doc();
      final walletTransactionRef = _walletTransactionsRef.doc();

      final orderData = order.toFirestore();

      await _firestore.runTransaction((transaction) async {
        
        transaction.set(orderRef, orderData);

        final userId = orderData['user_id']?.toString() ?? '';
        final paymentMethod =
            orderData['payment_method']?.toString().toLowerCase() ?? '';
        final status = orderData['status']?.toString().toLowerCase() ?? '';

        final dynamic totalValue =
            orderData['total_amount'] ?? orderData['total_price'] ?? 0;

        final int totalAmount = totalValue is int
            ? totalValue
            : int.tryParse(totalValue.toString()) ?? 0;

        
        
        if (userId.isNotEmpty &&
            paymentMethod == 'ewallet' &&
            status == 'paid' &&
            totalAmount > 0) {
          transaction.set(walletTransactionRef, {
            'wallet_id': userId,
            'type': 'payment',
            'amount': totalAmount,
            'description': 'Pembayaran pesanan',
            'status': 'success',
            'order_id': orderRef.id,
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      });

      debugPrint('[ORDER DS] Pesanan dibuat: ${orderRef.id}');
      debugPrint('[ORDER DS] Transaksi pembayaran wallet dicatat');

      return orderRef.id;
    } catch (e) {
      debugPrint('[ORDER DS] Error createOrder: $e');
      rethrow;
    }
  }

  
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersRef.doc(orderId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint('[ORDER DS] Status pesanan $orderId → $status');
    } catch (e) {
      debugPrint('[ORDER DS] Error updateOrderStatus: $e');
      rethrow;
    }
  }

  
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await _ordersRef
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('[ORDER DS] Error getUserOrders: $e');
      rethrow;
    }
  }
}