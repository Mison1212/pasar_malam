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
import 'package:pasar_malam/core/widgets/auth_guard.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String dashboard = '/dashboard';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String productDetail = '/product-detail';

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
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
