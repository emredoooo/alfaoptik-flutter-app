// lib/screens/inventory/add_product_form.dart

import 'package:alfaoptik/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk input formatter

class AddProductForm extends StatefulWidget {
  // Nanti bisa ditambahkan parameter seperti branchId jika diperlukan
  const AddProductForm({super.key});

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();

  bool _isLoading = false;

  // Controllers untuk setiap input field
  final _productNameController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _initialStockController = TextEditingController();
  // --- BARU: Tambahkan controller untuk field baru ---
  final _brandController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _descriptionController = TextEditingController();


  String? _selectedCategory;
  bool _trackSerialBatch = false;

  final List<String> _categories = [
    'Frame Kacamata',
    'Lensa Kontak',
    'Lensa Kacamata',
    'Cairan Pembersih',
    'Aksesoris Optik'
  ];

  @override
  void dispose() {
    _productNameController.dispose();
    _productCodeController.dispose();
    _sellingPriceController.dispose();
    _initialStockController.dispose();
    // --- BARU: Jangan lupa dispose controller baru ---
    _brandController.dispose();
    _purchasePriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // --- DISESUAIKAN: Tambahkan data baru ke Map ---
      Map<String, dynamic> productData = {
        "name": _productNameController.text,
        "product_code": _productCodeController.text,
        "category": _selectedCategory,
        "price": double.tryParse(_sellingPriceController.text) ?? 0,
        "stock": int.tryParse(_initialStockController.text) ?? 0,
        "track_serial_batch": _trackSerialBatch,
        "brand": _brandController.text, // Data baru
        "purchase_price": double.tryParse(_purchasePriceController.text) ?? 0, // Data baru
        "description": _descriptionController.text, // Data baru
        "branch_code": "TBB" 
      };

      try {
        await _productService.addProduct(productData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil ditambahkan!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productCodeController,
                decoration: const InputDecoration(labelText: 'Kode Produk/SKU'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kode produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
               // --- BARU: Tambahkan TextFormField untuk Merek ---
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Merek Produk (Opsional)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Kategori Produk'),
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 12),
              // --- BARU: Tambahkan TextFormField untuk Harga Beli ---
              TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(labelText: 'Harga Beli (Opsional)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sellingPriceController,
                decoration: const InputDecoration(labelText: 'Harga Jual'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harga jual tidak boleh kosong';
                  if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
                  if (double.parse(value) <= 0) return 'Harga jual harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _initialStockController,
                decoration: const InputDecoration(labelText: 'Stok Awal'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Stok awal tidak boleh kosong';
                  if (int.tryParse(value) == null) return 'Masukkan angka bulat yang valid';
                  if (int.parse(value) < 0) return 'Stok tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // --- BARU: Tambahkan TextFormField untuk Deskripsi ---
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi (Opsional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Lacak Nomor Seri/Batch'),
                value: _trackSerialBatch,
                onChanged: (bool value) {
                  setState(() {
                    _trackSerialBatch = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Produk'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}