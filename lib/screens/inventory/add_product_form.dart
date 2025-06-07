import 'package:flutter/material.dart';

class AddProductForm extends StatefulWidget {
  // Nanti bisa ditambahkan parameter seperti branchId jika diperlukan
  const AddProductForm({super.key});

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk setiap input field
  final _productNameController = TextEditingController();
  final _productCodeController = TextEditingController();
  // Tambahkan controller lain sesuai field di database:
  // _brandNameController, _descriptionController, _purchasePriceController,
  // _sellingPriceController, _unitController, _initialStockController,
  // _minStockLevelController

  String? _selectedCategory; // Untuk dropdown kategori
  bool _trackSerialBatch = false;

  // Contoh daftar kategori (idealnya diambil dari database)
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
    // Dispose controller lainnya
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Jika form valid, kumpulkan data
      final productName = _productNameController.text;
      final productCode = _productCodeController.text;
      // Ambil data dari controller lain

      print('Nama Produk: $productName');
      print('Kode Produk: $productCode');
      print('Kategori: $_selectedCategory');
      print('Lacak Serial/Batch: $_trackSerialBatch');
      // Print data lainnya

      // --- TAHAP SELANJUTNYA ---
      // 1. Siapkan data untuk dikirim ke API (backend Node.js)
      // Map<String, dynamic> productData = {
      //   'productName': productName,
      //   'productCode': productCode,
      //   'categoryId': _selectedCategory, // (perlu mapping ke ID kategori)
      //   'brandName': _brandNameController.text,
      //   // ... field lainnya
      //   'initialStock': int.tryParse(_initialStockController.text) ?? 0,
      //   'branchId': 'ID_CABANG_SAAT_INI' // (didapat dari sesi login admin cabang)
      // };

      // 2. Panggil API untuk menyimpan produk baru
      // try {
      //   // Response response = await ApiService.post('/products/add', productData);
      //   // if (response.statusCode == 201) {
      //   //   ScaffoldMessenger.of(context).showSnackBar(
      //   //     SnackBar(content: Text('Produk berhasil ditambahkan!')),
      //   //   );
      //   //   Navigator.pop(context); // Kembali ke halaman sebelumnya atau daftar produk
      //   // } else {
      //   //   // Tangani error dari server
      //   // }
      // } catch (e) {
      //   // Tangani error koneksi atau lainnya
      // }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proses penambahan produk (simulasi)...')),
      );
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              // Tambahkan TextFormField untuk:
              // - Merek
              // - Deskripsi
              // - Harga Beli
              // - Harga Jual (angka)
              // - Satuan Produk
              // - Stok Awal (angka)
              // - Batas Stok Minimum (angka)
              // - Upload Gambar (lebih kompleks, untuk awal bisa berupa input URL atau diabaikan)

              TextFormField(
                // controller: _sellingPriceController,
                decoration: const InputDecoration(labelText: 'Harga Jual'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harga jual tidak boleh kosong';
                  if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
                  if (double.parse(value) <= 0) return 'Harga jual harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                // controller: _initialStockController,
                decoration: const InputDecoration(labelText: 'Stok Awal'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Stok awal tidak boleh kosong';
                  if (int.tryParse(value) == null) return 'Masukkan angka bulat yang valid';
                  if (int.parse(value) < 0) return 'Stok tidak boleh negatif';
                  return null;
                },
              ),
               const SizedBox(height: 10),
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
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Simpan Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}