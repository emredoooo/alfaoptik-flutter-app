// lib/screens/history/transaction_history_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_session.dart';
import '../../services/history_service.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final HistoryService _historyService = HistoryService();
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
     print("--- DEBUG: initState() Halaman Riwayat Transaksi DIMULAI. ---");
    super.initState();
    final now = DateTime.now();
    _startDate = now.subtract(const Duration(days: 30));
    _endDate = now;
    _fetchHistory();
  }

Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    
    String? branchCodeForApi;
    // JIKA BUKAN ADMIN PUSAT, branchCode WAJIB ADA.
    if (UserSession.role != 'Admin Pusat') {
      branchCodeForApi = UserSession.branchCode;
      
      // INI ADALAH BAGIAN PENGAMAN YANG PENTING
      if (branchCodeForApi == null || branchCodeForApi.isEmpty) {
        print("Error: Akun Admin Cabang ini tidak memiliki branch_code di sesinya.");
        if (mounted) {
          setState(() {
            _isLoading = false;
            _transactions = []; // Pastikan daftar transaksi dikosongkan
          });
        }
        // Tampilkan pesan error yang jelas ke pengguna
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal memuat data: Akun Anda tidak terhubung dengan cabang manapun.'),
          backgroundColor: Colors.red,
        ));
        return; // Hentikan eksekusi fungsi agar tidak meminta semua data
      }
    }
    
    // Kode di bawah ini hanya akan berjalan jika branchCodeForApi valid (untuk Admin Cabang)
    // atau jika pengguna adalah Admin Pusat.
    try {
      final historyData = await _historyService.getTransactionHistory(
        startDate: _startDate,
        endDate: _endDate,
        branchCode: branchCodeForApi,
      );
      if (mounted) {
        setState(() {
          _transactions = historyData;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showDateRangePicker() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: _startDate!,
        end: _endDate!,
      ),
      helpText: 'Pilih Rentang Tanggal Riwayat',
    );

    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
      _fetchHistory();
    }
  }

  // Fungsi format mata uang dibuat lebih aman
  String formatCurrency(String? amountString) {
      // Coba parse string ke double, jika gagal atau null, anggap 0
      final double amount = double.tryParse(amountString ?? '0') ?? 0;
      return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: _showDateRangePicker,
            tooltip: 'Filter Tanggal',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.date_range, size: 16, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('d MMM yy').format(_startDate!)} - ${DateFormat('d MMM yy').format(_endDate!)}',
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? Center(
                        child: Text('Tidak ada riwayat transaksi pada periode ini.'),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchHistory,
                        child: ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final trx = _transactions[index];
                            final trxDate = trx['transaction_date'] != null
                                ? DateTime.parse(trx['transaction_date'])
                                : DateTime.now();
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                title: Text(
                                  trx['invoice_number'] ?? 'No. Invois tidak ada',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${DateFormat('d MMM yy, HH:mm').format(trxDate)}\n'
                                  'Pelanggan: ${trx['customer_name'] ?? 'Umum'}',
                                ),
                                isThreeLine: true,
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      // --- PERBAIKAN UTAMA DI SINI ---
                                      // Panggil formatCurrency dengan data String
                                      formatCurrency(trx['total_amount']),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(trx['payment_method'] ?? '-'),
                                  ],
                                ),
                                onTap: () {
                                  // TODO: Navigasi ke halaman detail/struk transaksi
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}