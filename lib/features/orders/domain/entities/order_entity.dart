import 'package:equatable/equatable.dart';

/// Entity yang merepresentasikan sebuah pesanan (order).
/// Menyimpan status pembayaran dan detail item yang dipesan.
class OrderEntity extends Equatable {
  final String? id;
  final String userId;
  final List<Map<String, dynamic>> items; // Daftar produk yang dipesan
  final double totalAmount;
  final String status;          // "pending_payment", "paid", "canceled"
  final String paymentMethod;   // "ewallet"
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderEntity({
    this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  /// Cek apakah pesanan sudah dibayar
  bool get isPaid => status == 'paid';

  /// Cek apakah pesanan masih menunggu pembayaran
  bool get isPending => status == 'pending_payment';

  @override
  List<Object?> get props => [
        id, userId, items, totalAmount, status, paymentMethod,
        createdAt, updatedAt,
      ];
}
