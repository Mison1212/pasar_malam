import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/dashboard/presentation/providers/product_provider.dart';
import 'package:pasar_malam/features/cart/presentation/providers/cart_provider.dart';
import 'package:pasar_malam/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:pasar_malam/features/orders/presentation/providers/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authProvider = AuthProvider();
  final productProvider = ProductProvider();
  final cartProvider = CartProvider();
  final walletProvider = WalletProvider();   // Provider E-Wallet baru
  final orderProvider = OrderProvider();     // Provider Orders baru

  authProvider.onLogin = (String userId) async {
    await Future.wait([
      cartProvider.loadUserCart(userId),
      productProvider.loadUserLikes(userId),
      walletProvider.loadWallet(userId),     // Load wallet saat login
    ]);
  };

  authProvider.onSignOut = (String userId) async {
    await Future.wait([
      cartProvider.saveAndClearForUser(userId),
      productProvider.saveAndClearForUser(userId),
    ]);
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: productProvider),
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider.value(value: walletProvider),   // Register E-Wallet
        ChangeNotifierProvider.value(value: orderProvider),     // Register Orders
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fashion Papua',
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
