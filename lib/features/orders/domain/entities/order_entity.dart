import 'package:equatable/equatable.dart';



class OrderEntity extends Equatable {
  final String? id;
  final String userId;
  final List<Map<String, dynamic>> items; 
  final double totalAmount;
  final String status;          
  final String paymentMethod;   
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

  
  bool get isPaid => status == 'paid';

  
  bool get isPending => status == 'pending_payment';

  @override
  List<Object?> get props => [
        id, userId, items, totalAmount, status, paymentMethod,
        createdAt, updatedAt,
      ];
}
