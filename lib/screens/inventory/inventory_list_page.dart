// lib/screens/inventory/inventory_list_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Impor fungsi format mata uang dan model Product jika perlu
// Untuk contoh ini, kita buat data tiruan dulu
class Product {
  final String name;
  final String sku;
  final int stock;
  final double price;
  Product({required this.name, required this.sku, required this.stock, required this.price});
}
String formatCurrency(double amount) => 'Rp ${NumberFormat('#,###', 'id_ID').format(amount)}';


class InventoryListPage extends StatefulWidget {
  const InventoryListPage({super.key});

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  // Data inventaris contoh (nantinya dari API)
  final List<Product> _inventoryItems = [
    Product(name: "Frame Elegan Visto 501", sku: "FK001", stock: 15, price: 750000),
    Product(name: "Lensa Progresif DigitalMax", sku: "LK001", stock: 8, price: 1500000),
    Product(name: "Lensa Kontak Bening AquaDay", sku: "LC001", stock: 25, price: 280000),
    Product(name: "Kacamata Hitam Polarized Cruiser", sku: "SG001", stock: 12, price: 650000),
    Product(name: "Cairan Pembersih MultiOpti 60ml", sku: "CP001", stock: 48, price: 45000),
  ];

  List<Product> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _inventoryItems;
  }

  void _filterInventory(String query) {
    List<Product> filteredList = _inventoryItems.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase()) ||
             item.sku.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      _filteredItems = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Inventaris'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              onChanged: _filterInventory,
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
      body: ListView.builder(
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('SKU: ${item.sku}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Stok: ${item.stock}',
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/addProduct');
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}