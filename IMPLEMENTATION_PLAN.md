# Integrasi Pembayaran E-Wallet via Deep Link

## Alur Deep Link Payment

1. User tekan "Bayar via E-Wallet App" di Checkout
2. Marketplace buat order di Firestore (status: pending_payment)  
3. Marketplace generate + buka deep link: `myewallet://pay?order_id=xxx&amount=50000&callback=mymarketplace://payment_result`
4. E-Wallet App terbuka → user konfirmasi & bayar
5. E-Wallet buka callback: `mymarketplace://payment_result?order_id=xxx&status=success`
6. Marketplace listener tangkap callback → POST ke PHP API → update MySQL
7. UI navigasi ke OrderSuccessPage

## Files to Create/Modify

| File | Action |
|---|---|
| pubspec.yaml | MODIFY - add url_launcher + app_links |
| AndroidManifest.xml | MODIFY - intent filter + queries |
| Info.plist | MODIFY - URL scheme + queries |
| deep_link_service.dart | NEW - singleton deep link service |
| api_constants.dart | MODIFY - add updateOrderStatus endpoint |
| order_provider.dart | MODIFY - pending order + callback handler |
| checkout_page.dart | MODIFY - new button + deep link listener |
| payment_result_page.dart | NEW - callback result UI |
| app_router.dart | MODIFY - new route |
| main.dart | MODIFY - init deep link + navigator key |
| update_order_status.php | NEW - PHP endpoint for MySQL |
