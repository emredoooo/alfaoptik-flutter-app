// lib/services/transaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionService {
  // Pastikan URL ini sesuai dengan setup Anda (10.0.2.2 untuk Android Emulator)
  //final String _baseUrl = 'http://10.0.2.2:3000/api';
  final String _baseUrl =
      'https://alfa.aiti.biz.id/API'; // Untuk Flutter Web/iOS Sim

  // Mengirim data transaksi ke backend untuk disimpan
  Future<Map<String, dynamic>> saveTransaction(
    Map<String, dynamic> transactionData,
  ) async {
    final String apiUrl = '$_baseUrl/transactions';
    print('Mengirim transaksi ke: $apiUrl'); // Untuk debugging

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(transactionData), // Encode data Map ke string JSON
      );

      if (response.statusCode == 201) {
        // 201 Created: Transaksi berhasil dibuat
        final responseData = jsonDecode(response.body);
        print('Respons dari server: $responseData');
        return responseData; // Mengembalikan data dari server (misal, { message, transactionId, invoiceNumber })
      } else {
        // Jika server mengembalikan error
        print('Gagal menyimpan transaksi. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
          'Gagal menyimpan transaksi (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      // Tangani error koneksi atau lainnya
      print('Error saat menghubungi service transaksi: $e');
      throw Exception('Gagal terhubung ke server untuk menyimpan transaksi.');
    }
  }
}
