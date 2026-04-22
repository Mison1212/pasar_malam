import 'package:flutter/material.dart';
import 'package:pasar_malam/core/routes/app_router.dart';
import 'package:pasar_malam/features/auth/presentation/providers/auth_provider.dart';
import 'package:pasar_malam/features/dashboard/presentation/providers/product_provider.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final product = context.watch<ProductProvider>();

    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 4,
        toolbarHeight: 75, 
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black45,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FASHION PAPUA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Halo, ${auth.firebaseUser?.displayName ?? 'Mison Wenda'} 👋',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                  onPressed: () => _showCartSheet(context, product),
                ),
              ),
              if (product.likedProductIds.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF3949AB), width: 1.5),
                    ),
                    child: Text(
                      '${product.likedProductIds.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 22),
              onPressed: () async {
                await auth.signOut();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, AppRouter.login);
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Membuka Form Tambah Produk...')),
          );
        },
        backgroundColor: const Color(0xFF1A237E),
        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
        label: const Text(
          'Tambah Produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: switch (product.status) {
        ProductStatus.loading || ProductStatus.initial => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF1A237E),
              ),
              SizedBox(height: 16),
              Text(
                'Menyiapkan produk terbaik...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        ProductStatus.error => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                product.error ?? 'Gagal memuat data',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => product.fetchProducts(),
              ),
            ],
          ),
        ),

        ProductStatus.loaded => RefreshIndicator(
          onRefresh: () => product.fetchProducts(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16), 
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Text(
                    'Koleksi Eksklusif',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
                SizedBox(
                  height: 280,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: product.products.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final p = product.products[i];
                      return Container(
                        width: 180, 
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20), 
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    child: Image.network(
                                      p.imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[50],
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey[300],
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.3),
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GreenBadge(p.category),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Material(
                                      color: Colors.white.withOpacity(0.95),
                                      shape: const CircleBorder(),
                                      elevation: 2,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(50),
                                        onTap: () => product.toggleLike(p.id),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            product.likedProductIds.contains(p.id)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: product.likedProductIds.contains(p.id)
                                                ? Colors.redAccent
                                                : Colors.grey[400],
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.black87,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Harga',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Rp ${p.price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                                          style: const TextStyle(
                                            color: Color(0xFF1B5E20),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    'Katalog Tambahan (Baris Baru)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
                SizedBox(
                  height: 280,
                  // Ini adalah placeholder (titipan) list kedua.
                  // Saat ini isinya saya samakan dengan produk yang di atas.
                  // Nanti Anda tinggal mengubah product.products menjadi variabel baru 
                  // dari database Anda (misal product.katalogBaru).
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: product.products.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final p = product.products[i];
                      return Container(
                        width: 180, 
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20), 
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    child: Image.network(
                                      p.imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[50],
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey[300],
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.3),
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GreenBadge(p.category),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Material(
                                      color: Colors.white.withOpacity(0.95),
                                      shape: const CircleBorder(),
                                      elevation: 2,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(50),
                                        onTap: () => product.toggleLike(p.id),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            product.likedProductIds.contains(p.id)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: product.likedProductIds.contains(p.id)
                                                ? Colors.redAccent
                                                : Colors.grey[400],
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.black87,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Harga',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Rp ${p.price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                                          style: const TextStyle(
                                            color: Color(0xFF1B5E20),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100), 
              ],
            ),
          ),
        ),
      },
    );
  }

  Widget GreenBadge(String category) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          category,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showCartSheet(BuildContext context, ProductProvider product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final likedProducts = product.products
            .where((p) => product.likedProductIds.contains(p.id))
            .toList();

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_cart, color: Color(0xFF1A237E)),
                    const SizedBox(width: 8),
                    const Text(
                      'Keranjang Disukai',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${likedProducts.length} Item',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 30),
              if (likedProducts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'Belum ada produk yang disukai',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: likedProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = likedProducts[index];
                      return Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              p.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${p.price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              product.toggleLike(p.id);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
