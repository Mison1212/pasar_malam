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

  ProductStatus get status => _status;
  List<ProductModel> get products => _products;
  String? get error => _error;
  bool get isLoading => _status == ProductStatus.loading;

  // Fetch products — token otomatis disertakan oleh DioClient interceptor
  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    notifyListeners();

    try {
      final response = await DioClient.instance.get(ApiConstants.products);

      // PERBAIKAN DI SINI:
      // Karena PHP kamu langsung mengirim list [{}, {}],
      // maka response.data sudah langsung berupa List, bukan Map yang punya kunci 'data'.

      final List<dynamic> data = response.data; // Hapus ['data']

      _products = data.map((e) => ProductModel.fromJson(e)).toList();
      _status = ProductStatus.loaded;
      _error = null; // Reset error jika berhasil
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Gagal memuat produk';
      _status = ProductStatus.error;
      print("Dio Error: ${e.message}");
    } catch (e) {
      // Tangkap error parsing jika Model tidak cocok
      _error = 'Terjadi kesalahan data';
      _status = ProductStatus.error;
      print("Parsing Error: $e");
    }

    notifyListeners();
  }
}
