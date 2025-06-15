// lib/screens/reports/reports_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user_session.dart';
import '../../services/branch_service.dart';
import '../../services/report_service.dart'; // PASTIKAN IMPORT INI ADA

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
  DateTime? _startDate;
  DateTime? _endDate;
  dynamic _selectedBranch;
  
  bool _isLoading = false;
  bool _isLoadingBranches = false;
  List<dynamic> _branches = [];
  Map<String, dynamic>? _reportData;
  final BranchService _branchService = BranchService();
  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;

    if (UserSession.role == 'Admin Pusat') {
      _loadBranches();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _generateReport());
    }
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoadingBranches = true);
    try {
      final branchesData = await _branchService.getBranches();
      if (mounted) setState(() => _branches = branchesData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat cabang: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingBranches = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _generateReport() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan pilih rentang tanggal.')));
      return;
    }
    
    setState(() {
      _isLoading = true;
      _reportData = null; 
    });

    String? branchCodeForApi;
    if (UserSession.role != 'Admin Pusat') {
        branchCodeForApi = UserSession.branchCode;
        // PENGAMAN: Sama seperti di halaman riwayat
        if (branchCodeForApi == null || branchCodeForApi.isEmpty) {
            print("Error: Admin Cabang ini tidak memiliki branch code di sesinya.");
            if(mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Gagal memuat laporan: Akun Anda tidak terhubung dengan cabang.'),
                    backgroundColor: Colors.red,
                ));
            }
            return;
        }
    } else {
        // Untuk admin pusat, ambil dari dropdown
        branchCodeForApi = _selectedBranch?['branch_code'];
    }

    try {
      final data = await _reportService.getSalesReport(
        startDate: _startDate!,
        endDate: _endDate!,
        branchCode: branchCodeForApi,
      );

      if (mounted) {
        setState(() { _reportData = data; });
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
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdminPusat = UserSession.role == 'Admin Pusat';

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Laporan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: InkWell(onTap: () => _selectDate(context, true), child: InputDecorator(decoration: const InputDecoration(labelText: 'Dari Tanggal'), child: Text(_startDate != null ? DateFormat('dd MMM yy').format(_startDate!) : 'Pilih')))),
                const SizedBox(width: 12),
                Expanded(child: InkWell(onTap: () => _selectDate(context, false), child: InputDecorator(decoration: const InputDecoration(labelText: 'Sampai Tanggal'), child: Text(_endDate != null ? DateFormat('dd MMM yy').format(_endDate!) : 'Pilih')))),
              ],
            ),
            const SizedBox(height: 16),

            if (isAdminPusat)
              _isLoadingBranches
                  ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                  : DropdownButtonFormField<dynamic>(
                      value: _selectedBranch,
                      decoration: const InputDecoration(labelText: 'Pilih Cabang'),
                      hint: const Text('Semua Cabang'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<dynamic>(value: null, child: Text('Semua Cabang')),
                        ..._branches.map<DropdownMenuItem<dynamic>>((branch) => DropdownMenuItem<dynamic>(value: branch, child: Text(branch['branch_name']))).toList(),
                      ],
                      onChanged: (value) => setState(() => _selectedBranch = value),
                    )
            else
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Laporan untuk Cabang', enabled: false),
                child: Text(UserSession.branchName ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),

            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _isLoading ? null : _generateReport, icon: _isLoading ? Container(width: 20, height: 20, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Icon(Icons.bar_chart), label: const Text('Tampilkan Laporan'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
            const Divider(height: 32, thickness: 1),
            
            if (_isLoading)
              const Center(heightFactor: 5, child: CircularProgressIndicator())
            else if (_reportData == null)
              const Center(heightFactor: 5, child: Text('Silakan pilih filter dan tampilkan laporan.'))
            else
              _buildReportContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    final summary = _reportData?['summary'] as Map<String, dynamic>? ?? {};
    final topProducts = _reportData?['top_selling_products'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ringkasan Laporan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12, crossAxisSpacing: 12,
          childAspectRatio: 2.0,
          children: [
            _buildSummaryCard('Total Omzet', formatCurrency((summary['total_revenue'] as num?)?.toDouble() ?? 0.0), Icons.monetization_on_outlined, Colors.green),
            _buildSummaryCard('Jml Transaksi', '${summary['total_transactions'] ?? 0}', Icons.receipt_long_outlined, Colors.blue),
            _buildSummaryCard('Rata-rata/Trx', formatCurrency((summary['average_transaction_value'] as num?)?.toDouble() ?? 0.0), Icons.trending_up_outlined, Colors.orange),
          ],
        ),
        const Divider(height: 32, thickness: 1),
        Text('Produk Terlaris', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          child: topProducts.isEmpty
              ? const ListTile(title: Text('Tidak ada data produk terjual pada periode ini.'))
              : Column(
                  children: List.generate(
                    topProducts.length,
                    (index) {
                      final product = topProducts[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(product['product_name'] ?? 'Nama Produk Tidak Ada'),
                        trailing: Text('${product['total_quantity_sold'] ?? 0} Pcs', style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}