// lib/screens/pos/pos_page.dart
import 'package:flutter/material.dart';
import 'package:alfaoptik/widgets/app_drawer.dart';
import '../../services/product_service.dart'; // Sesuaikan path jika perlu

class CartItem { // CartItem bisa tetap di sini atau dipindah ke model
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
  final ProductService _productService = ProductService(); // Instance service

  // State untuk data produk, loading, dan error
  List<Product> _availableProducts = []; // Produk asli dari "API"
  List<Product> _filteredProducts = [];  // Produk yang ditampilkan setelah filter
  bool _isLoadingProducts = true;
  String? _productErrorMessage;

  // State untuk Keranjang Belanja
  final List<CartItem> _shoppingCart = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialProducts(); // Ambil produk saat halaman dimuat
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
      final products = await _productService.fetchProducts();
      setState(() {
        _availableProducts = products;
        _filteredProducts = List.from(_availableProducts); // Awalnya tampilkan semua
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _productErrorMessage = e.toString();
        _isLoadingProducts = false;
      });
    }
  }

  // Jika pencarian ingin memanggil API (server-side search)
  // Future<void> _fetchProductsWithQuery(String query) async {
  //   setState(() {
  //     _isLoadingProducts = true; // Tampilkan loading untuk pencarian server-side
  //     _productErrorMessage = null;
  //   });
  //   try {
  //     final products = await _productService.fetchProducts(searchQuery: query);
  //     setState(() {
  //       _availableProducts = products; // Atau _filteredProducts langsung
  //       _filteredProducts = List.from(_availableProducts);
  //       _isLoadingProducts = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _productErrorMessage = e.toString();
  //       _isLoadingProducts = false;
  //     });
  //   }
  // }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    // Untuk saat ini, kita tetap filter di client-side setelah data awal diambil
    // Jika ingin server-side search, panggil _fetchProductsWithQuery(query)
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_availableProducts);
      } else {
        _filteredProducts = _availableProducts
            .where((product) => product.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  // --- Fungsi Logout, addToCart, calculateTotal, increment, decrement tetap sama ---
  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _addToCart(Product product) {
    setState(() {
      var existingItemIndex =
          _shoppingCart.indexWhere((item) => item.product.id == product.id);
      if (existingItemIndex != -1) {
        _shoppingCart[existingItemIndex].quantity++;
      } else {
        _shoppingCart.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in _shoppingCart) {
      total += item.totalPrice;
    }
    return total;
  }

  void _incrementQuantity(CartItem cartItem) {
    setState(() { cartItem.quantity++; });
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTwoColumnLayout = screenWidth > 700;

    Widget productListContent;
    if (_isLoadingProducts) {
      productListContent = const Center(child: CircularProgressIndicator());
    } else if (_productErrorMessage != null) {
      productListContent = Center(
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
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
            child: ListTile(
              title: Text(product.name),
              subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
              trailing: IconButton(
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
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk (nama)...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear(); // Listener akan memanggil _onSearchChanged
                          },
                        )
                      : null,
                ),
              ),
            ),
            const Divider(),
            Expanded(child: productListContent), // Tampilkan konten produk di sini
          ],
        ),
      ),
    );

    // --- Widget shoppingCartSection, Scaffold, Drawer tetap sama ---
    // (Salin dari kode sebelumnya, tidak ada perubahan signifikan di bagian ini
    // kecuali memastikan menggunakan model Product dan CartItem yang konsisten)
    Widget shoppingCartSection = Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
           boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(-3, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Keranjang Belanja (${_shoppingCart.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            Expanded(
              child: _shoppingCart.isEmpty
                  ? const Center(
                      child: Text('Keranjang masih kosong.', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      itemCount: _shoppingCart.length,
                      itemBuilder: (context, index) {
                        final cartItem = _shoppingCart[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: Text(cartItem.product.name, style: const TextStyle(fontSize: 14)),
                            subtitle: Text(
                                'Rp ${cartItem.product.price.toStringAsFixed(0)} x ${cartItem.quantity} = Rp ${cartItem.totalPrice.toStringAsFixed(0)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => _decrementQuantity(cartItem),
                                  tooltip: 'Kurangi',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                                  onPressed: () => _incrementQuantity(cartItem),
                                  tooltip: 'Tambah',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                Text('Rp ${_calculateTotal().toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Diskon:', style: TextStyle(fontSize: 16)),
                Text('Rp 0',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Rp ${_calculateTotal().toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18)),
              onPressed: _shoppingCart.isEmpty
                  ? null
                  : () async { // Jadikan async untuk menangani hasil dari Navigator.pushNamed
                      final result = await Navigator.pushNamed(
                        context,
                        '/checkout',
                        arguments: {
                          'cartItems': List<CartItem>.from(_shoppingCart), // Kirim salinan agar tidak termodifikasi langsung
                          'totalAmount': _calculateTotal(),
                        },
                      );

                      // Jika CheckoutPage mengirim 'true' saat pop (setelah pembayaran sukses)
                      if (result == true) {
                        setState(() {
                          _shoppingCart.clear();
                          _searchController.clear(); // Bersihkan juga pencarian
                          // Mungkin juga refresh daftar produk jika ada perubahan stok
                          // _fetchInitialProducts(); // Jika perlu reload data produk
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaksi baru siap! Keranjang telah dikosongkan.')),
                        );
                      }
                    },
              child: const Text('Bayar'),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alfa Optik'),
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