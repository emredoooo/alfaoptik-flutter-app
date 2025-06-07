// lib/screens/reports/reports_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Fungsi format mata uang
String formatCurrency(double amount, {String locale = 'id_ID', String symbol = 'Rp '}) {
  final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 0);
  return format.format(amount);
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic>? _reportData;

  void _showDatePicker() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fungsi pilih bulan/tahun akan dibuat nanti.')),
    );
  }

  void _generateReport() {
    setState(() {
      _isLoading = true;
      _reportData = null; // Kosongkan data lama saat laporan baru dibuat
    });
    print('Membuat laporan untuk: ${DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate)}');
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) { // Cek apakah widget masih ada di tree
        setState(() {
          _reportData = {
            "summary": {
              "total_revenue": 15750000.0,
              "total_transactions": 45,
              "average_transaction_value": 350000.0,
            },
            "top_selling_products": [
              {"product_name": "Lensa Progresif DigitalMax", "total_quantity_sold": 10},
              {"product_name": "Frame Elegan Visto 501", "total_quantity_sold": 8},
              {"product_name": "Kacamata Hitam Polarized Cruiser", "total_quantity_sold": 7},
              {"product_name": "Lensa Kontak Bening Harian AquaDay", "total_quantity_sold": 5},
              {"product_name": "Cairan Pembersih Lensa OptiFresh 120ml", "total_quantity_sold": 4},
            ],
            "daily_sales": [],
          };
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Periode Laporan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _showDatePicker,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Bulan & Tahun',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateReport,
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Tampilkan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 1),
            if (_isLoading)
              const Center(heightFactor: 5, child: CircularProgressIndicator())
            else if (_reportData == null)
              const Center(
                heightFactor: 5,
                child: Text('Silakan pilih periode dan tampilkan laporan.'),
              )
            else
              _buildReportContent(),
          ],
        ),
      ),
    );
  }

  // Widget baru untuk membangun konten laporan jika data ada
  Widget _buildReportContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Bulan ${DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate)}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.0,
          children: [
            _buildSummaryCard(
              'Total Omzet',
              formatCurrency(_reportData!['summary']['total_revenue'] ?? 0.0),
              Icons.monetization_on_outlined, Colors.green,
            ),
            _buildSummaryCard(
              'Jumlah Transaksi',
              '${_reportData!['summary']['total_transactions'] ?? 0} Transaksi',
              Icons.receipt_long_outlined, Colors.blue,
            ),
            _buildSummaryCard(
              'Rata-rata/Transaksi',
              formatCurrency(_reportData!['summary']['average_transaction_value'] ?? 0.0),
              Icons.trending_up_outlined, Colors.orange,
            ),
          ],
        ),
        const Divider(height: 32, thickness: 1),
        Text('5 Produk Terlaris', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(
              _reportData!['top_selling_products'].length,
              (index) {
                final product = _reportData!['top_selling_products'][index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(product['product_name']),
                  trailing: Text('${product['total_quantity_sold']} Pcs', style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ),
        const Divider(height: 32, thickness: 1),
        Text('Grafik Penjualan Harian', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          child: Container(
            height: 250,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Text(
                'Grafik akan ditampilkan di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =================================================================
  // ===         FUNGSI YANG DIPERBAIKI - TANPA SPACER           ===
  // =================================================================
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Menggunakan MainAxisAlignment.spaceBetween untuk mendorong konten
          // ke atas dan ke bawah kartu secara otomatis.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gunakan Expanded agar teks tidak overflow jika judulnya panjang
                Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyLarge, overflow: TextOverflow.ellipsis)),
                Icon(icon, color: color),
              ],
            ),
            // Tidak perlu Spacer lagi di sini
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}