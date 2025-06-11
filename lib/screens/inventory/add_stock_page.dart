// lib/screens/inventory/add_stock_page.dart
import 'package:flutter/material.dart';
import 'package:alfaoptik/services/product_service.dart'; // Untuk mengakses model Product dan service

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

  // Fungsi _selectProduct tidak ada perubahan...
  Future<void> _selectProduct() async {
    final List<Product> products = await _productService.fetchProducts(branchCode: 'TBB');
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

  // --- PERBARUI FUNGSI _submitAddStock MENJADI SEPERTI INI ---
  void _submitAddStock() async { // Jadikan async
    if (_formKey.currentState!.validate()) {
      if (_selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih produk terlebih dahulu.')),
        );
        return;
      }

      setState(() { _isLoading = true; });

      final int quantityToAdd = int.parse(_quantityController.text);

      try {
        await _productService.addStock(
          productId: _selectedProduct!.id,
          quantity: quantityToAdd,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stok berhasil ditambahkan!')),
          );
          Navigator.of(context).pop(true); // Kirim 'true' untuk menandakan ada update
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  // --- Widget build tidak ada perubahan signifikan, hanya pastikan tombol memanggil _submitAddStock ---
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
              // Pemilihan Produk (tidak berubah)
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

              // Input Kuantitas (tidak berubah)
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

              // Tombol Simpan
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