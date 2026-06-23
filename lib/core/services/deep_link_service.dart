import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';

class DeepLinkService {
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static late AppLinks _appLinks;
  static StreamSubscription<Uri>? _linkSubscription;

  static Future<void> init() async {
    _appLinks = AppLinks();

    
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });

    
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleLink(initialUri);
        });
      }
    } catch (e) {
      debugPrint("Error initial deep link: $e");
    }
  }

  static void _handleLink(Uri uri) {
    debugPrint("DEEP LINK DITERIMA: $uri");
    
    
    if (uri.scheme == 'mymarketplace' && uri.host == 'payment_result') {
      final status = uri.queryParameters['status'];
      final orderId = uri.queryParameters['order_id'];

      if (status != null && orderId != null) {
        
        navigatorKey.currentState?.pushNamed(
          AppRouter.paymentResult,
          arguments: {
            'status': status,
            'orderId': orderId,
          },
        );
        
        
        if (status == 'success') {
          
          
        }
      }
    }
  }

  static void dispose() {
    _linkSubscription?.cancel();
  }
}
