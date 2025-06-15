// lib/services/branch_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BranchService {
  // TODO: Ganti dengan URL base API Anda dari file konfigurasi
  final String _baseUrl = 'http://localhost:3000/api';

  /// Mengambil daftar semua cabang dari server
  Future<List<dynamic>> getBranches() async {
    final String apiUrl = '$_baseUrl/branches';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal memuat daftar cabang: ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}