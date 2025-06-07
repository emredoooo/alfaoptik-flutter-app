// lib/services/product_service.dart
import 'dart:convert';    // Untuk jsonDecode
import 'package:http/http.dart' as http; // Package untuk HTTP request

// Model Product (pastikan field-nya sesuai dengan JSON dari API Anda)
class Product {
  final dynamic id; // Bisa String atau int tergantung output API Anda
  final String? product_code; // Sesuaikan nama field jika berbeda
  final String name;
  final String? category;
  final String? brand;
  final String? description;
  final double price; // selling_price dari backend
  final double? purchase_price;
  final String? unit;
  final bool? track_serial_batch;
  final String? image_url;

  Product({
    required this.id,
    this.product_code,
    required this.name,
    this.category,
    this.brand,
    this.description,
    required this.price,
    this.purchase_price,
    this.unit,
    this.track_serial_batch,
    this.image_url,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'], // Pastikan ini sesuai dengan output JSON backend Anda
      product_code: json['product_code'] as String?,
      name: json['name'] as String,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(), // Pastikan ini 'selling_price' dari backend
      purchase_price: json['purchase_price'] != null ? (json['purchase_price'] as num).toDouble() : null,
      unit: json['unit'] as String?,
      track_serial_batch: json['track_serial_batch'] as bool?,
      image_url: json['image_url'] as String?,
    );
  }
}

class ProductService {
  // ---- PENTING: URL API Backend Anda ----
  // Jika Anda menjalankan Flutter di Android Emulator, gunakan '10.0.2.2' untuk merujuk ke localhost PC Anda.
  // Jika Anda menjalankan Flutter Web di PC yang sama dengan server, 'localhost' atau '127.0.0.1' seharusnya bisa.
  // Jika Anda menjalankan di perangkat fisik, gunakan alamat IP lokal PC Anda di jaringan WiFi yang sama.
  //final String _baseUrl = 'http://10.0.2.2:3000/api'; // Untuk Android Emulator
   final String _baseUrl = 'http://localhost:3000/api'; // Untuk Flutter Web atau iOS Simulator

  Future<List<Product>> fetchProducts({String? searchQuery}) async {
    String apiUrl = '$_baseUrl/products';
    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Jika API backend Anda mendukung filter via query parameter:
      // apiUrl += '?search=${Uri.encodeQueryComponent(searchQuery)}';
    }

    print('Fetching products from: $apiUrl'); // Untuk debugging

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Jika server mengembalikan respons OK (200)
        List<dynamic> body = jsonDecode(response.body);
        List<Product> products = body
            .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        print('Products fetched successfully: ${products.length} items');
        return products;
      } else {
        // Jika server tidak mengembalikan respons OK
        print('Failed to load products. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Gagal memuat produk dari server (Status: ${response.statusCode})');
      }
    } catch (e) {
      // Tangani error koneksi atau parsing
      print('Error fetching products: $e');
      throw Exception('Gagal terhubung ke server atau memproses data: $e');
    }
  }
}