class ApiConstants {
  // 1. baseUrl hanya sampai folder di htdocs
  static const String baseUrl = 'http://192.168.100.69/api_php';

  // 2. Endpoint produk langsung ke nama file PHP-nya
  static const String products = '/products.php';

  // Endpoint lainnya (disesuaikan jika nanti ada file php-nya)
  static const String verifyToken = '/verify_token.php';

  // Timeout tetap sama
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
