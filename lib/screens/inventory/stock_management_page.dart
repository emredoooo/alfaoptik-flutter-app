// lib/screens/inventory/stock_management_page.dart
import 'package:alfaoptik/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCurrency(double amount) => 'Rp ${NumberFormat('#,###', 'id_ID').format(amount)}';

class StockManagementPage extends StatefulWidget {
  const StockManagementPage({super.key});

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _inventoryFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inventoryFuture = _fetchInventory();
    _searchController.addListener(_filterInventory);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInventory);
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Product>> _fetchInventory() async {
    try {
      // Kirim kode cabang saat fetch data
      final products = await _productService.fetchProducts(branchCode: 'TBB');
      if (mounted) {
        setState(() {
          _allProducts = products;
          _filteredProducts = products;
        });
      }
      return products;
    } catch (e) {
      throw Exception('Gagal memuat data inventaris: ${e.toString()}');
    }
  }

  void _filterInventory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((item) {
        final productName = item.name.toLowerCase();
        final productSku = item.product_code?.toLowerCase() ?? '';
        return productName.contains(query) || productSku.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: 'Tambah Stok',
            onPressed: () {
              Navigator.pushNamed(context, '/addStock').then((result) {
                // Refresh daftar jika penambahan stok berhasil
                if (result == true) {
                  setState(() {
                    _inventoryFuture = _fetchInventory();
                  });
                }
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama atau SKU...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInventory,
        child: FutureBuilder<List<Product>>(
          future: _inventoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                ),
              );
            }

            if (_filteredProducts.isEmpty) {
              return const Center(
                child: Text('Tidak ada produk ditemukan.'),
              );
            }

            return ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final item = _filteredProducts[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('SKU: ${item.product_code ?? 'N/A'}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Stok: ${item.stock}', // <-- GUNAKAN DATA STOK ASLI
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: item.stock < 10 ? Colors.red.shade700 : Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(formatCurrency(item.price)),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigasi ke halaman detail/edit produk
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/addProduct').then((_) {
            // Refresh daftar inventaris setelah kembali dari halaman tambah produk
            setState(() {
              _inventoryFuture = _fetchInventory();
            });
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}