// lib/screens/inventory/add_stock_page.dart
import 'package:flutter/material.dart';
import 'package:alfaoptik/services/product_service.dart'; // Untuk mengakses model Product

class AddStockPage extends StatefulWidget {
  const AddStockPage({super.key});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  Product? _selectedProduct;
  final TextEditingController _quantityController = TextEditingController();
  bool _isLoading = false;

  // Fungsi untuk menampilkan dialog pencarian produk
  Future<void> _selectProduct() async {
    // Nantinya, ini bisa menjadi halaman pencarian produk yang lebih canggih.
    // Untuk sekarang, kita tampilkan dialog sederhana dengan daftar produk dari API.
    final List<Product> products = await _productService.fetchProducts(branchCode: 'TBB'); // Ambil semua produk

    // ignore: use_build_context_synchronously
    final Product? selected = await showDialog<Product>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Produk'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(products[index].name),
                subtitle: Text('Stok saat ini: ${products[index].stock}'),
                onTap: () {
                  Navigator.of(context).pop(products[index]);
                },
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedProduct = selected;
      });
    }
  }

  // Fungsi untuk memproses penambahan stok
  void _submitAddStock() {
    if (_formKey.currentState!.validate()) {
      if (_selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih produk terlebih dahulu.')),
        );
        return;
      }

      setState(() { _isLoading = true; });

      final int quantityToAdd = int.parse(_quantityController.text);

      // TODO: Panggil InventoryService untuk mengirim data ke API
      // await InventoryService.addStock(
      //   productId: _selectedProduct!.id,
      //   branchId: 1, // Placeholder untuk ID cabang 'TBB'
      //   quantity: quantityToAdd,
      // );

      // --- Simulasi untuk sekarang ---
      print('Menambah stok untuk produk ID: ${_selectedProduct!.id}');
      print('Cabang ID: 1 (Placeholder)');
      print('Jumlah ditambahkan: $quantityToAdd');

      Future.delayed(const Duration(seconds: 1)).then((_) {
        if (mounted) {
          setState(() { _isLoading = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stok berhasil ditambahkan! (Simulasi)')),
          );
          Navigator.of(context).pop(true); // Kirim 'true' untuk menandakan ada update
        }
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Stok Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- Pemilihan Produk ---
              InkWell(
                onTap: _selectProduct,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Produk',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedProduct?.name ?? 'Ketuk untuk memilih produk'),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Input Kuantitas ---
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Stok yang Ditambahkan',
                  hintText: 'Masukkan angka',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong.';
                  }
                  final n = int.tryParse(value);
                  if (n == null) {
                    return 'Masukkan angka yang valid.';
                  }
                  if (n <= 0) {
                    return 'Jumlah harus lebih dari 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // --- Tombol Simpan ---
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitAddStock,
                icon: _isLoading
                    ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Icon(Icons.add_circle_outline),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Penambahan Stok'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}