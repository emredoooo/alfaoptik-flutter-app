// lib/screens/receipt/receipt_page.dart
import 'dart:typed_data';
import 'package:alfaoptik/models/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../pos/pos_page.dart';

// Fungsi format mata uang
String formatCurrency(double amount, {String locale = 'id_ID', String symbol = 'Rp '}) {
  final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 0);
  return format.format(amount);
}

class ReceiptPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const ReceiptPage({super.key, required this.transactionData});

  // =================================================================
  // ===         FUNGSI PDF DENGAN PERBAIKAN PADA DAFTAR ITEM    ===
  // =================================================================
  Future<Uint8List> _generateReceiptPdf(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    // Ekstraksi data
    final String invoiceNumber = transactionData['invoice_number_final'] ?? transactionData['invoice_number_simulated'] ?? 'N/A';
    final String transactionDate = transactionData['transaction_date_formatted'] ?? 'N/A';
    final String transactionTime = transactionData['transaction_time_formatted'] ?? 'N/A';
    final List<Map<String, dynamic>> items = (transactionData['items'] as List<dynamic>?)?.map((item) => item as Map<String, dynamic>).toList() ?? [];
    final double totalAmount = (transactionData['total_amount'] as num?)?.toDouble() ?? 0.0;
    final String paymentMethod = transactionData['payment_method'] ?? 'N/A';
    final double amountReceived = (transactionData['amount_received'] as num?)?.toDouble() ?? 0.0;
    final double changeAmount = (transactionData['change_amount'] as num?)?.toDouble() ?? 0.0;
    final String branchNameToDisplay = transactionData['branch_name'] ?? 'N/A';
    final Map<String, dynamic>? customerDetails = (transactionData['customer_data'] as Map<String, dynamic>?);
    final String customerName = customerDetails?['name'] ?? '';
    final String referenceNumber = transactionData['reference_number'] ?? '';
    final String notes = transactionData['notes'] ?? '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- Kop Struk ---
              pw.SizedBox(width: double.infinity, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                    pw.Text('ALFA OPTIK', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text(branchNameToDisplay, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Jl. Raya Pulung Kencana No. 123', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('Telp: (0721) 555-0101', style: const pw.TextStyle(fontSize: 8)),
                  ])),
              pw.SizedBox(height: 8), pw.Divider(thickness: 1), pw.SizedBox(height: 8),

              // --- Info Transaksi ---
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text('No: $invoiceNumber', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('$transactionDate $transactionTime', style: const pw.TextStyle(fontSize: 8)),
                ]),
              if (customerName.isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(top: 4), child: pw.Text('Pelanggan: $customerName', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 8), pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed), pw.SizedBox(height: 8),

              // --- Daftar Item (PERBAIKAN DI SINI) ---
              // Menggunakan 'for' loop untuk membangun daftar widget secara dinamis
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
              // --- AKHIR PERBAIKAN ---

              pw.SizedBox(height: 8), pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed), pw.SizedBox(height: 8),
              
              // --- Total & Pembayaran ---
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('TOTAL', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)), pw.Text(formatCurrency(totalAmount), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))]),
              pw.SizedBox(height: 8), pw.Divider(thickness: 1), pw.SizedBox(height: 8),
              pw.Text('Metode Bayar: ${paymentMethod.toUpperCase()}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              if (paymentMethod.toLowerCase() == 'tunai') ...[
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('BAYAR (TUNAI)', style: const pw.TextStyle(fontSize: 9)), pw.Text(formatCurrency(amountReceived), style: const pw.TextStyle(fontSize: 9))]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('KEMBALI', style: const pw.TextStyle(fontSize: 9)), pw.Text(formatCurrency(changeAmount), style: const pw.TextStyle(fontSize: 9))]),
              ],
              if ((paymentMethod.toLowerCase() == 'kartu' || paymentMethod.toLowerCase() == 'qris') && referenceNumber.isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 1.0), child: pw.Text('Ref: $referenceNumber', style: const pw.TextStyle(fontSize: 9))),
              if (notes.isNotEmpty) ...[
                pw.SizedBox(height: 5), pw.Divider(height: 1.0),
                pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 3.0), child: pw.Text('Catatan: $notes', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 8))),
              ],
              
              // --- Footer ---
              pw.SizedBox(height: 15),
              pw.Center(child: pw.Text('Terima Kasih Atas Kunjungan Anda', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
              pw.Center(child: pw.Text('Periksakan mata anda di Alfa Optik', style: const pw.TextStyle(fontSize: 7))),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    // Ekstraksi data untuk UI di layar (tidak ada perubahan di sini)
    final String invoiceNumber = transactionData['invoice_number_final'] ?? transactionData['invoice_number_simulated'] ?? 'N/A';
    final String transactionDate = transactionData['transaction_date_formatted'] ?? '';
    final String transactionTime = transactionData['transaction_time_formatted'] ?? '';
    final List<Map<String, dynamic>> items = (transactionData['items'] as List<dynamic>?)?.map((item) => item as Map<String, dynamic>).toList() ?? [];
    final double totalAmount = (transactionData['total_amount'] as num?)?.toDouble() ?? 0.0;
    final String paymentMethod = transactionData['payment_method'] ?? 'N/A';
    final double amountReceived = (transactionData['amount_received'] as num?)?.toDouble() ?? 0.0;
    final double changeAmount = (transactionData['change_amount'] as num?)?.toDouble() ?? 0.0;
    final String branchNameToDisplay = transactionData['branch_name'] ?? 'N/A';
    final Map<String, dynamic>? customerDetails = (transactionData['customer_data'] as Map<String, dynamic>?);
    final String customerName = customerDetails?['name'] ?? '';
    final String notes = transactionData['notes'] ?? '';
    final String referenceNumber = transactionData['reference_number'] ?? '';

    return Scaffold(
      appBar: AppBar(
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
            // Bagian Kop Struk
            Center(child: Column(children: [
                const Text('ALFA OPTIK', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                Text(branchNameToDisplay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                const Text('Jl. Raya Pulung Kencana No. 123', style: TextStyle(fontSize: 13)),
                const Text('Tubaba, Lampung', style: TextStyle(fontSize: 13)),
                const Text('Telp: (0721) 555-0101', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 10),
                const Divider(thickness: 1.0),
              ])),
            const SizedBox(height: 12),
            // Informasi Transaksi
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('No: $invoiceNumber', style: const TextStyle(fontSize: 13)),
                Text('$transactionDate $transactionTime', style: const TextStyle(fontSize: 13)),
              ]),
            if (customerName.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 3.0), child: Text('Pelanggan: $customerName', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            const SizedBox(height: 5),
            const Divider(thickness: 1.0, height: 10),
            // Daftar Item
            const Text("RINCIAN PEMBELIAN:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(padding: const EdgeInsets.symmetric(vertical: 3.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item['product_name'] ?? 'Nama Produk Tidak Ada', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('  ${item['quantity']} x ${formatCurrency((item['price_per_item'] as num?)?.toDouble() ?? 0.0)}', style: const TextStyle(fontSize: 14)),
                          Text(formatCurrency((item['subtotal'] as num?)?.toDouble() ?? 0.0), style: const TextStyle(fontSize: 14)),
                        ])]));
              },
            ),
            const Divider(thickness: 1.0, height: 10),
            // Bagian Total
            Padding(padding: const EdgeInsets.only(top: 8.0, bottom: 2.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(formatCurrency(totalAmount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ])),
            const SizedBox(height: 5),
            const Divider(thickness: 2.0, color: Colors.black87),
            // Detail Pembayaran
            Padding(padding: const EdgeInsets.only(top: 8.0, bottom: 2.0), child: Text('Metode Bayar   : ${paymentMethod.toUpperCase()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            if (paymentMethod.toLowerCase() == 'tunai') ...[
              Padding(padding: const EdgeInsets.symmetric(vertical: 1.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('BAYAR (TUNAI)', style: TextStyle(fontSize: 14)), Text(formatCurrency(amountReceived), style: const TextStyle(fontSize: 14))])),
              Padding(padding: const EdgeInsets.symmetric(vertical: 1.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('KEMBALI', style: TextStyle(fontSize: 14)), Text(formatCurrency(changeAmount), style: const TextStyle(fontSize: 14))])),
            ],
            if ((paymentMethod.toLowerCase() == 'kartu' || paymentMethod.toLowerCase() == 'qris') && referenceNumber.isNotEmpty)
              Padding(padding: const EdgeInsets.symmetric(vertical: 1.0), child: Text('No. Referensi    : $referenceNumber', style: const TextStyle(fontSize: 14))),
            if (notes.isNotEmpty) ...[
               const SizedBox(height: 5), const Divider(height: 1.0),
               Padding(padding: const EdgeInsets.symmetric(vertical: 3.0), child: Text('Catatan: $notes', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13))),
            ],
            const SizedBox(height: 25),
            // Ucapan Terima Kasih
            const Center(child: Text('TERIMA KASIH ATAS KUNJUNGAN ANDA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            const SizedBox(height: 4),
            const Center(child: Text('Barang yang sudah dibeli tidak dapat ditukar/dikembalikan.', style: TextStyle(fontSize: 13))),
            const SizedBox(height: 20),
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
              onPressed: () {
                Printing.layoutPdf(onLayout: (PdfPageFormat format) => _generateReceiptPdf(format));
              },
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