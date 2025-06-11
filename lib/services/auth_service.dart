// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Sesuaikan URL jika perlu
  final String _baseUrl = 'http://localhost:3000/api';

  // Fungsi untuk melakukan login
  Future<Map<String, dynamic>> login(String username, String password) async {
    final String apiUrl = '$_baseUrl/auth/login';
    print('Mencoba login ke: $apiUrl');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 200 OK: Login berhasil, kembalikan data user
        print('Login berhasil untuk user: ${responseBody['user']['username']}');
        return responseBody['user'];
      } else {
        // Jika server mengembalikan error (misal: 401 Unauthorized)
        // Lempar exception dengan pesan dari server
        throw Exception(responseBody['message'] ?? 'Gagal untuk login.');
      }
    } catch (e) {
      // Tangani error koneksi atau lainnya
      print('Error saat menghubungi service auth: $e');
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }
}