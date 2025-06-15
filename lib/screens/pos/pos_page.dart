// lib/screens/pos/pos_page.dart (Versi Final Gabungan)
import 'package:flutter/material.dart';
import 'package:alfaoptik/widgets/app_drawer.dart';
import '../../services/product_service.dart';
import '../scanner/barcode_scanner_page.dart';
import '../../models/user_session.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get totalPrice => product.price * quantity;
}

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final ProductService _productService = ProductService();
  List<Product> _availableProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoadingProducts = true;
  String? _productErrorMessage;
  final List<CartItem> _shoppingCart = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productErrorMessage = null;
    });
    try {
      // Default ke 'TBB' jika Admin Pusat tidak punya cabang, bisa disesuaikan
      String? branchCodeToFetch = UserSession.branchCode ?? 'TBB';
      if (UserSession.role == 'Admin Pusat' && _availableProducts.isNotEmpty) {
        // Jika admin pusat, jangan fetch otomatis, biarkan dia pilih cabang di halaman lain
        // Untuk halaman POS ini, kita asumsikan ia beroperasi di cabang default
      }
      
      final products = await _productService.fetchProducts(
        branchCode: branchCodeToFetch,
      );
      if(mounted) {
        setState(() {
          _availableProducts = products;
          _filteredProducts = List.from(_availableProducts);
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _productErrorMessage = e.toString();
          _isLoadingProducts = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_availableProducts);
      } else {
        _filteredProducts = _availableProducts
            .where((product) =>
                product.name.toLowerCase().contains(query) ||
                (product.product_code?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  void _logout(BuildContext context) {
    // Implementasi logout Anda sudah benar
    UserSession.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // --- LOGIKA UTAMA YANG DIPERBAIKI ---

  void _addToCart(Product product) {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Stok produk ini telah habis.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      final existingItemIndex = _shoppingCart.indexWhere((item) => item.product.id == product.id);

      if (existingItemIndex != -1) {
        // Jika item sudah ada di keranjang, cek sebelum menambah
        if (_shoppingCart[existingItemIndex].quantity < product.stock) {
          _shoppingCart[existingItemIndex].quantity++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Jumlah di keranjang sudah mencapai stok maksimum (${product.stock}).'), backgroundColor: Colors.orange));
        }
      } else {
        // Jika item baru, langsung tambahkan
        _shoppingCart.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  double _calculateTotal() {
    return _shoppingCart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _incrementQuantity(CartItem cartItem) {
    setState(() {
      // Cek stok sebelum menambah jumlah
      if (cartItem.quantity < cartItem.product.stock) {
        cartItem.quantity++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stok maksimum untuk ${cartItem.product.name} adalah ${cartItem.product.stock}.'), backgroundColor: Colors.orange));
      }
    });
  }

  void _decrementQuantity(CartItem cartItem) {
    setState(() {
      if (cartItem.quantity > 1) {
        cartItem.quantity--;
      } else {
        _shoppingCart.remove(cartItem);
      }
    });
  }
  
  // --- AKHIR DARI LOGIKA YANG DIPERBAIKI ---

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTwoColumnLayout = screenWidth > 700;

    Widget productListContent;
    if (_isLoadingProducts) {
      productListContent = const Center(child: CircularProgressIndicator());
    } else if (_productErrorMessage != null) {
      productListContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Gagal memuat produk: $_productErrorMessage', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                onPressed: _fetchInitialProducts,
              ),
            ],
          ),
        ),
      );
    } else if (_filteredProducts.isEmpty) {
      productListContent = Center(
        child: Text(
          _searchController.text.isEmpty && _availableProducts.isEmpty
              ? 'Tidak ada produk tersedia.'
              : 'Produk tidak ditemukan untuk "${_searchController.text}".',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      productListContent = ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          final bool isOutOfStock = product.stock <= 0;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            color: isOutOfStock ? Colors.grey.shade200 : Colors.white,
            child: ListTile(
              title: Text(product.name, style: TextStyle(color: isOutOfStock ? Colors.grey.shade700 : Colors.black87)),
              subtitle: Text(
                'Rp ${product.price.toStringAsFixed(0)} | Stok: ${product.stock}',
                style: TextStyle(fontWeight: FontWeight.w500, color: isOutOfStock ? Colors.red.shade700 : Colors.black54),
              ),
              trailing: isOutOfStock
                  ? const Chip(label: Text('Habis'), backgroundColor: Color(0xFFfbe9e7), labelStyle: TextStyle(color: Color(0xFFc63f31)))
                  : IconButton(
                      icon: const Icon(Icons.add_shopping_cart, color: Colors.blueAccent),
                      tooltip: 'Tambah ke Keranjang',
                      onPressed: () => _addToCart(product),
                    ),
            ),
          );
        },
      );
    }

    Widget productListSection = Expanded(
      flex: isTwoColumnLayout ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk atau pindai barcode...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner_outlined),
                    tooltip: 'Pindai Barcode',
                    onPressed: () async {
                      final String? barcode = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const BarcodeScannerPage()));
                      if (barcode != null && barcode.isNotEmpty) {
                        _searchController.text = barcode;
                      }
                    },
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(child: productListContent),
          ],
        ),
      ),
    );

    Widget shoppingCartSection = Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(-3, 0))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Keranjang Belanja (${_shoppingCart.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            Expanded(
              child: _shoppingCart.isEmpty
                  ? const Center(child: Text('Keranjang masih kosong.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _shoppingCart.length,
                      itemBuilder: (context, index) {
                        final cartItem = _shoppingCart[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: Text(cartItem.product.name, style: const TextStyle(fontSize: 14)),
                            subtitle: Text('Rp ${cartItem.product.price.toStringAsFixed(0)} x ${cartItem.quantity}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 22), onPressed: () => _decrementQuantity(cartItem)),
                                Text('${cartItem.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 22), onPressed: () => _incrementQuantity(cartItem)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Rp ${_calculateTotal().toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0), textStyle: const TextStyle(fontSize: 18)),
              onPressed: _shoppingCart.isEmpty ? null : () {
                Navigator.pushNamed(context, '/checkout', arguments: {'cartItems': List<CartItem>.from(_shoppingCart), 'totalAmount': _calculateTotal()});
              },
              child: const Text('Bayar'),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alfa Optik POS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: isTwoColumnLayout
          ? Row(children: [productListSection, shoppingCartSection])
          : Column(children: [Expanded(child: productListSection), SizedBox(height: MediaQuery.of(context).size.height * 0.45, child: shoppingCartSection)]),
    );
  }
}