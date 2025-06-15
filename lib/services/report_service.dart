// lib/services/report_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ReportService {
  final String _baseUrl = 'http://127.0.0.1:3000/api';

  Future<Map<String, dynamic>> getSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    String? branchCode,
  }) async {
    final String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final Map<String, String> queryParameters = {
      'startDate': formattedStartDate,
      'endDate': formattedEndDate,
    };
    if (branchCode != null && branchCode.isNotEmpty) {
      queryParameters['branchCode'] = branchCode;
    }

    // --- TAMBAHKAN BLOK DEBUG INI ---
    print("\n--- DEBUG REPORT SERVICE ---");
    print("Branch Code yang dikirim ke API: ${queryParameters['branchCode']}");
    print("----------------------------\n");
    // --------------------------------

    final uri = Uri.parse('$_baseUrl/reports/sales').replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal memuat laporan dari server');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server. Pastikan server API berjalan.');
    }
  }
}