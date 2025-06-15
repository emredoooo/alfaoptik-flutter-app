// lib/services/history_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryService {
  final String _baseUrl = 'http://127.0.0.1:3000/api';

  Future<List<dynamic>> getTransactionHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? branchCode,
  }) async {
    final now = DateTime.now();
    final String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate ?? now.subtract(const Duration(days: 30)));
    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate ?? now);

    final Map<String, String> queryParameters = {
      'startDate': formattedStartDate,
      'endDate': formattedEndDate,
    };
    if (branchCode != null && branchCode.isNotEmpty) {
      queryParameters['branchCode'] = branchCode;
    }

    // --- TAMBAHKAN BLOK DEBUG INI ---
    print("\n--- DEBUG HISTORY SERVICE ---");
    print("Branch Code yang dikirim ke API: ${queryParameters['branchCode']}");
    print("-----------------------------\n");
    // --------------------------------

    final uri = Uri.parse('$_baseUrl/transactions').replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal memuat riwayat transaksi');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server. Pastikan server API berjalan.');
    }
  }
}