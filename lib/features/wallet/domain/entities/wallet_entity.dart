import 'package:equatable/equatable.dart';

/// Entity yang merepresentasikan dompet digital user.
/// Ini adalah objek domain murni, tanpa dependensi framework.
class WalletEntity extends Equatable {
  final String userId;
  final double balance;
  final bool isPinSet;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WalletEntity({
    required this.userId,
    required this.balance,
    required this.isPinSet,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [userId, balance, isPinSet, createdAt, updatedAt];
}
