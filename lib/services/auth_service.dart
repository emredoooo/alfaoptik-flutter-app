// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Kita gunakan 127.0.0.1 agar lebih konsisten
  final String _baseUrl = 'http://127.0.0.1:3000/api';

  Future<Map<String, dynamic>> login(String username, String password) async {

    print("--- DEBUG FLUTTER: Mengirim user: [$username], pass: [$password] ---");
    // ----------------------------------------------------------------

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
        return responseBody['user'];
      } else {
        // Jika server menolak (status code bukan 200), lemparkan pesan dari server.
        throw Exception(responseBody['message'] ?? 'Gagal untuk login.');
      }
    } catch (e) {
      // Tangani error koneksi atau lainnya.
      print('Error saat menghubungi service auth: $e');
      if (e.toString().contains('Failed host lookup') || e.toString().contains('Connection refused')) {
         throw Exception('Tidak dapat terhubung ke server.');
      }
      // Melempar kembali pesan error yang lebih bersih.
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }
}