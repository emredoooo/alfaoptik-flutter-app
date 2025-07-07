// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String _baseUrl = 'https://alfa.aiti.biz.id/API';

  /// Mengambil daftar semua pengguna dari server
  Future<List<dynamic>> getUsers() async {
    final String apiUrl = '$_baseUrl/users';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal memuat daftar pengguna: ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

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

  /// Membuat pengguna baru
  Future<void> createUser(Map<String, dynamic> userData) async {
    final String apiUrl = '$_baseUrl/users';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(userData),
      );
      if (response.statusCode != 201) {
        // 201 Created
        throw Exception('Gagal membuat pengguna: ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  /// Mengedit/memperbarui data pengguna
  Future<void> updateUser(int userId, Map<String, dynamic> userData) async {
    final String apiUrl = '$_baseUrl/users/$userId';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(userData),
      );
      if (response.statusCode != 200) {
        // 200 OK
        throw Exception('Gagal memperbarui pengguna: ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}
