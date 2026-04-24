import 'package:flutter/material.dart';
import 'package:pasar_malam/core/services/user_data_storage.dart';
import 'package:pasar_malam/features/dashboard/data/models/product_model.dart';
import 'package:pasar_malam/features/cart/data/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItemModel> _items = {};

  Map<int, CartItemModel> get items => _items;
  int get itemCount => _items.length;

  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }


  Future<void> loadUserCart(String userId) async {
    _items.clear();
    final savedItems = await UserDataStorage.loadCart(userId);
    for (final itemJson in savedItems) {
      try {
        final product = ProductModel.fromJson(itemJson['product'] as Map<String, dynamic>);
        final quantity = itemJson['quantity'] as int? ?? 1;
        _items[product.id] = CartItemModel(product: product, quantity: quantity);
      } catch (_) {
      }
    }
    notifyListeners();
  }

  Future<void> _saveCart(String userId) async {
    final cartJson = _items.values
        .map((item) => {
              'product': item.product.toJson(),
              'quantity': item.quantity,
            })
        .toList();
    await UserDataStorage.saveCart(userId, cartJson);
  }


  void addItem(ProductModel product, {String? userId}) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItemModel(product: product),
      );
    }
    notifyListeners();
    if (userId != null) _saveCart(userId);
  }

  void removeItem(int productId, {String? userId}) {
    _items.remove(productId);
    notifyListeners();
    if (userId != null) _saveCart(userId);
  }

  void removeSingleItem(int productId, {String? userId}) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => existingCartItem.copyWith(
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
    if (userId != null) _saveCart(userId);
  }

  void clearCart({String? userId}) {
    _items.clear();
    notifyListeners();
    if (userId != null) _saveCart(userId);
  }

  Future<void> saveAndClearForUser(String userId) async {
    await _saveCart(userId);
    _items.clear();
    notifyListeners();
  }

  void clearUserData() {
    _items.clear();
    notifyListeners();
  }
}
