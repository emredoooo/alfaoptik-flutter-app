// lib/screens/receipt/receipt_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Fungsi format mata uang tidak berubah
String formatCurrency(double amount, {String locale = 'id_ID', String symbol = 'Rp '}) {
  final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 0);
  return format.format(amount);
}

class ReceiptPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const ReceiptPage({super.key, required this.transactionData});

  Future<Uint8List> _generateReceiptPdf(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    // --- PERBAIKAN PENGAMBILAN DATA DI SINI ---
    final String invoiceNumber = transactionData['invoiceNumber'] ?? 'N/A';
    final String transactionDate = transactionData['transaction_date_formatted'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String transactionTime = transactionData['transaction_time_formatted'] ?? DateFormat('HH:mm:ss').format(DateTime.now());
    final List<Map<String, dynamic>> items = (transactionData['items'] as List<dynamic>?)?.map((item) => item as Map<String, dynamic>).toList() ?? [];
    final double totalAmount = (transactionData['total_amount'] as num?)?.toDouble() ?? 0.0;
    final String paymentMethod = transactionData['payment_method'] ?? 'N/A';
    final double amountReceived = (transactionData['amount_received'] as num?)?.toDouble() ?? 0.0;
    final double changeAmount = (transactionData['change_amount'] as num?)?.toDouble() ?? 0.0;
    final String branchNameToDisplay = transactionData['branch_name'] ?? 'N/A';
    final Map<String, dynamic>? customerDetails = (transactionData['customer_data'] as Map<String, dynamic>?);
    final String customerName = customerDetails?['name'] ?? 'Umum';
    final String referenceNumber = transactionData['reference_number'] ?? '';
    final String notes = transactionData['notes'] ?? '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          // KONTEN PDF (Tidak ada perubahan signifikan, hanya memastikan variabel benar)
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(width: double.infinity, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                    pw.Text('ALFA OPTIK', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text(branchNameToDisplay, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Jl. Raya Pulung Kencana No. 123', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('Telp: (0721) 555-0101', style: const pw.TextStyle(fontSize: 8)),
                  ])),
              pw.SizedBox(height: 8), pw.Divider(thickness: 1), pw.SizedBox(height: 8),

              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text('No: $invoiceNumber', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('$transactionDate $transactionTime', style: const pw.TextStyle(fontSize: 8)),
                ]),
              if (customerName.isNotEmpty && customerName != 'Umum') pw.Padding(padding: const pw.EdgeInsets.only(top: 4), child: pw.Text('Pelanggan: $customerName', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 8), pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed), pw.SizedBox(height: 8),

              for (final item in items)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item['product_name'] ?? 'N/A', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('  ${item['quantity']} x ${formatCurrency((item['price_per_item'] as num?)?.toDouble() ?? 0.0)}', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text(formatCurrency((item['subtotal'] as num?)?.toDouble() ?? 0.0), style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
              pw.SizedBox(height: 8), pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed), pw.SizedBox(height: 8),
              
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('TOTAL', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)), pw.Text(formatCurrency(totalAmount), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))]),
              pw.SizedBox(height: 8), pw.Divider(thickness: 1), pw.SizedBox(height: 8),
              pw.Text('Metode Bayar: ${paymentMethod.toUpperCase()}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              if (paymentMethod.toLowerCase() == 'tunai') ...[
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('BAYAR (TUNAI)', style: const pw.TextStyle(fontSize: 9)), pw.Text(formatCurrency(amountReceived), style: const pw.TextStyle(fontSize: 9))]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('KEMBALI', style: const pw.TextStyle(fontSize: 9)), pw.Text(formatCurrency(changeAmount), style: const pw.TextStyle(fontSize: 9))]),
              ],
              
              pw.SizedBox(height: 15),
              pw.Center(child: pw.Text('Terima Kasih Atas Kunjungan Anda', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
              pw.Center(child: pw.Text('Barang yang sudah dibeli tidak dapat ditukar/dikembalikan.', style: const pw.TextStyle(fontSize: 7))),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    // --- PERBAIKAN UTAMA DI SINI ---
    final String invoiceNumber = transactionData['invoiceNumber'] ?? 'N/A';
    // --- (Sisa variabel lain juga dibuat lebih aman) ---
    final String transactionDate = transactionData['transaction_date_formatted'] ?? '';
    final String transactionTime = transactionData['transaction_time_formatted'] ?? '';
    final List<Map<String, dynamic>> items = (transactionData['items'] as List<dynamic>?)?.map((item) => item as Map<String, dynamic>).toList() ?? [];
    final double totalAmount = (transactionData['total_amount'] as num?)?.toDouble() ?? 0.0;
    final String paymentMethod = transactionData['payment_method'] ?? 'N/A';
    final double amountReceived = (transactionData['amount_received'] as num?)?.toDouble() ?? 0.0;
    final double changeAmount = (transactionData['change_amount'] as num?)?.toDouble() ?? 0.0;
    final String branchNameToDisplay = transactionData['branch_name'] ?? 'Cabang Tidak Diketahui';
    final String customerName = (transactionData['customer_data'] as Map?)?['name'] ?? 'Umum';

    return Scaffold(
      appBar: AppBar(
        // Gunakan variabel invoiceNumber yang sudah diperbaiki
        title: Text('Struk Pembayaran - $invoiceNumber'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Cetak Struk',
            onPressed: () => Printing.layoutPdf(onLayout: (PdfPageFormat format) => _generateReceiptPdf(format)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Column(children: [
                const Text('ALFA OPTIK', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                Text(branchNameToDisplay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10), const Divider(thickness: 1.0),
              ])),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('No: $invoiceNumber', style: const TextStyle(fontSize: 13)), // Tampil di sini
                Text('$transactionDate $transactionTime', style: const TextStyle(fontSize: 13)),
              ]),
            if (customerName.isNotEmpty && customerName != "Umum") Padding(padding: const EdgeInsets.symmetric(vertical: 3.0), child: Text('Pelanggan: $customerName', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            const SizedBox(height: 5),
            const Divider(thickness: 1.0, height: 10),
            
            // ... Sisa UI tidak perlu diubah, karena sudah menggunakan variabel di atas
            const Text("RINCIAN PEMBELIAN:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(padding: const EdgeInsets.symmetric(vertical: 3.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item['product_name'] ?? 'N/A', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('  ${item['quantity']} x ${formatCurrency((item['price_per_item'] as num?)?.toDouble() ?? 0.0)}', style: const TextStyle(fontSize: 14)),
                          Text(formatCurrency((item['subtotal'] as num?)?.toDouble() ?? 0.0), style: const TextStyle(fontSize: 14)),
                        ])]));
              },
            ),
            const Divider(thickness: 1.0, height: 10),
            Padding(padding: const EdgeInsets.only(top: 8.0, bottom: 2.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(formatCurrency(totalAmount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ])),
            
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.print_outlined),
              label: const Text('Cetak'),
              onPressed: () => Printing.layoutPdf(onLayout: (PdfPageFormat format) => _generateReceiptPdf(format)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: const Text('Transaksi Baru'),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/pos', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}