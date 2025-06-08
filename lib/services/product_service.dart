// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final dynamic id;
  final String? product_code;
  final String name;
  final String? category;
  final String? brand;
  final String? description;
  final double price;
  final double? purchase_price;
  final String? unit;
  final bool? track_serial_batch;
  final String? image_url;
  final int stock; // <-- TAMBAHKAN FIELD INI

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
    required this.stock, // <-- TAMBAHKAN DI KONSTRUKTOR
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      product_code: json['product_code'] as String?,
      name: json['name'] as String,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      purchase_price: json['purchase_price'] != null ? (json['purchase_price'] as num).toDouble() : null,
      unit: json['unit'] as String?,
      track_serial_batch: json['track_serial_batch'] as bool?,
      image_url: json['image_url'] as String?,
      stock: (json['stock'] as num?)?.toInt() ?? 0, // <-- TAMBAHKAN INI
    );
  }
}

class ProductService {
  final String _baseUrl = 'http://localhost:3000/api';

  // Perbarui fungsi untuk menerima branchCode
  Future<List<Product>> fetchProducts({String? branchCode}) async {
    // Tambahkan branchCode sebagai query parameter
    String apiUrl = '$_baseUrl/products?branch_code=${branchCode ?? 'TBB'}';

    print('Fetching products from: $apiUrl');

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Product> products = body
            .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        print('Products fetched successfully: ${products.length} items');
        return products;
      } else {
        throw Exception('Gagal memuat produk (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server untuk mengambil produk.');
    }
  }
}