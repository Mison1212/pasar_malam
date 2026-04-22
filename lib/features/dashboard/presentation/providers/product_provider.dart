import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pasar_malam/core/constants/api_constants.dart';
import 'package:pasar_malam/core/services/dio_client.dart';
import 'package:pasar_malam/features/dashboard/data/models/product_model.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  String? _error;
  final Set<int> _likedProductIds = {};

  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  String? get error => _error;
  bool get isLoading => _status == ProductStatus.loading;
  Set<int> get likedProductIds => _likedProductIds;

  void toggleLike(int productId) {
    if (_likedProductIds.contains(productId)) {
      _likedProductIds.remove(productId);
    } else {
      _likedProductIds.add(productId);
    }
    notifyListeners();
  }


  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      final response = await DioClient.instance.get(ApiConstants.products);

      var responseData = response.data;
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      final List<dynamic> data = responseData;

      _products = data.map((e) => ProductModel.fromJson(e)).toList();
      _status = ProductStatus.loaded;
      _error = null; 
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        _error = e.response?.data['message'] ?? 'Gagal memuat produk dari server';
      } else {
        _error = 'Koneksi ke server gagal (DioException)';
      }
      _status = ProductStatus.error;
      print("Dio Error: ${e.message}");
    } catch (e) {
      _error = 'Terjadi kesalahan data: $e';
      _status = ProductStatus.error;
      print("Parsing Error: $e");
    }

    notifyListeners();
  }
}
