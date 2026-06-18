import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasar_malam/features/orders/domain/entities/order_entity.dart';

/// Model Firestore untuk pesanan (orders).
class OrderModel extends OrderEntity {
  const OrderModel({
    super.id,
    required super.userId,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.paymentMethod,
    super.createdAt,
    super.updatedAt,
  });

  /// Membuat OrderModel dari document snapshot Firestore.
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel(
      id: doc.id,
      userId: data['user_id'] as String? ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      totalAmount: (data['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'pending_payment',
      paymentMethod: data['payment_method'] as String? ?? 'ewallet',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Konversi ke Map untuk disimpan ke Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'items': items,
      'total_amount': totalAmount,
      'status': status,
      'payment_method': paymentMethod,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
