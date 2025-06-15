import 'package:alfaoptik/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddStockPage extends StatefulWidget {
  final Product product;
  final int branchId; // Menerima ID cabang dari halaman sebelumnya

  const AddStockPage({
    super.key,
    required this.product,
    required this.branchId, // Parameter ini sekarang didefinisikan
  });

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final ProductService _productService = ProductService();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitAddStock() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      final int quantityToAdd = int.parse(_quantityController.text);
      
      // Panggil service untuk menambah stok dengan menyertakan branchId
      await _productService.addStock(
        productId: widget.product.id,
        quantity: quantityToAdd,
        branchId: widget.branchId, // Gunakan branchId yang diterima
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stok untuk ${widget.product.name} berhasil ditambahkan.'), backgroundColor: Colors.green),
        );
        // Kirim 'true' kembali ke halaman sebelumnya untuk menandakan sukses
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah stok: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Stok'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Produk:', style: Theme.of(context).textTheme.titleSmall),
              Text(
                widget.product.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Stok Saat Ini: ${widget.product.stock}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              TextFormField(
                controller: _quantityController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Jumlah Stok yang Ditambahkan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.add_shopping_cart),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong.';
                  }
                  final int? quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Masukkan jumlah yang valid (lebih dari 0).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isLoading ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Icon(Icons.save_outlined),
                  label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Penambahan Stok'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                  onPressed: _isLoading ? null : _submitAddStock,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}