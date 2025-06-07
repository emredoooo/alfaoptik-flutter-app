// lib/services/customer_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer_model.dart'; // Pastikan Anda punya file ini atau impor dari tempat lain

class CustomerService {
  // Pastikan URL ini sesuai dengan setup Anda (10.0.2.2 untuk Android Emulator)
  //final String _baseUrl = 'http://10.0.2.2:3000/api';
  final String _baseUrl = 'http://localhost:3000/api'; // Untuk Flutter Web/iOS Sim

  Future<Customer?> fetchCustomerByPhone(String phoneNumber) async {
    final String apiUrl = '$_baseUrl/customers/phone/$phoneNumber';
    print('Mencari pelanggan dari: $apiUrl'); // Untuk debugging

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // 200 OK: Pelanggan ditemukan
        final data = jsonDecode(response.body);
        print('Pelanggan ditemukan: $data');
        return Customer.fromJson(data); // Asumsi model Customer Anda punya factory fromJson
      } else if (response.statusCode == 404) {
        // 404 Not Found: Pelanggan tidak ditemukan, ini bukan error
        print('Pelanggan dengan no hp $phoneNumber tidak ditemukan.');
        return null;
      } else {
        // Error lain dari server (misal, 500 Internal Server Error)
        print('Gagal mencari pelanggan. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Gagal mencari pelanggan (Status: ${response.statusCode})');
      }
    } catch (e) {
      // Error koneksi atau lainnya
      print('Error saat menghubungi service pelanggan: $e');
      throw Exception('Gagal terhubung ke server untuk mencari pelanggan.');
    }
  }
}