import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    name: json['name']?.toString() ?? 'Tanpa Nama',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['image_url']?.toString() ?? '',
    category: json['category']?.toString() ?? 'Umum',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'category': category,
  };

  @override
  List<Object?> get props => [id, name, price, imageUrl, category];
}
