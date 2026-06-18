import 'package:flutter/material.dart';
import 'package:pasar_malam/features/auth/presentation/pages/login_page.dart';
import 'package:pasar_malam/features/auth/presentation/pages/register_page.dart';
import 'package:pasar_malam/features/auth/presentation/pages/verify_email_page.dart';
import 'package:pasar_malam/features/auth/presentation/pages/splash_page.dart';
import 'package:pasar_malam/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pasar_malam/features/dashboard/presentation/pages/product_detail_page.dart';
import 'package:pasar_malam/features/dashboard/data/models/product_model.dart';
import 'package:pasar_malam/features/cart/presentation/pages/cart_page.dart';
import 'package:pasar_malam/features/cart/presentation/pages/checkout_page.dart';
import 'package:pasar_malam/features/wallet/presentation/pages/wallet_dashboard_page.dart';
import 'package:pasar_malam/features/wallet/presentation/pages/topup_page.dart';
import 'package:pasar_malam/features/wallet/presentation/pages/setup_pin_page.dart';
import 'package:pasar_malam/features/orders/presentation/pages/order_success_page.dart';
import 'package:pasar_malam/core/widgets/auth_guard.dart';

class AppRouter {
  // ==================== ROUTE NAMES ====================
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard = '/dashboard';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String productDetail = '/product-detail';

  // Route baru untuk E-Wallet & Orders
  static const String wallet = '/wallet';
  static const String topUp = '/topup';
  static const String setupPin = '/setup-pin';
  static const String orderSuccess = '/order-success';

  // ==================== ROUTE GENERATOR ====================
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case verifyEmail:
        return MaterialPageRoute(builder: (_) => const VerifyEmailPage());
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: DashboardPage()),
        );
      case cart:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: CartPage()),
        );
      case checkout:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: CheckoutPage()),
        );
      case productDetail:
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) => AuthGuard(child: ProductDetailPage(product: product)),
        );

      // ==================== ROUTE E-WALLET ====================
      case wallet:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: WalletDashboardPage()),
        );
      case topUp:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: TopUpPage()),
        );
      case setupPin:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: SetupPinPage()),
        );

      // ==================== ROUTE ORDERS ====================
      case orderSuccess:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OrderSuccessPage(
            orderId: args['orderId'] as String,
            totalAmount: args['totalAmount'] as double,
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
