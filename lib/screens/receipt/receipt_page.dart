// lib/screens/receipt/receipt_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal/waktu jika perlu

// Fungsi format mata uang (bisa juga diimpor dari file utilitas jika sudah ada)
String formatCurrency(double amount, {String locale = 'id_ID', String symbol = 'Rp '}) {
  final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 0);
  return format.format(amount);
}

class ReceiptPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const ReceiptPage({super.key, required this.transactionData});

  @override
  Widget build(BuildContext context) {
    // Ekstraksi data dari transactionData dengan null safety
    final String invoiceNumber = transactionData['invoice_number_final'] ?? 'N/A';
    final String transactionDate = transactionData['transaction_date_formatted'] ?? // Menggunakan field yang sudah diformat dari CheckoutPage
                                   (transactionData['transaction_date_iso'] != null
                                       ? DateFormat('dd-MM-yyyy').format(DateTime.parse(transactionData['transaction_date_iso']))
                                       : 'N/A');
    final String transactionTime = transactionData['transaction_time_formatted'] ?? // Menggunakan field yang sudah diformat
                                   (transactionData['transaction_date_iso'] != null
                                       ? DateFormat('HH:mm:ss').format(DateTime.parse(transactionData['transaction_date_iso']))
                                       : 'N/A');
    final List<Map<String, dynamic>> items = (transactionData['items'] as List<dynamic>?)
                                                ?.map((item) => item as Map<String, dynamic>)
                                                ?.toList() ?? [];
    final double totalAmount = (transactionData['total_amount'] as num?)?.toDouble() ?? 0.0;
    final String paymentMethod = transactionData['payment_method'] ?? 'N/A';
    final double amountReceived = (transactionData['amount_received'] as num?)?.toDouble() ?? 0.0;
    final double changeAmount = (transactionData['change_amount'] as num?)?.toDouble() ?? 0.0;
    final String referenceNumber = transactionData['reference_number'] ?? '';
    final String notes = transactionData['notes'] ?? '';

    // Logika untuk menampilkan nama cabang (Pulung Kencana)
    final String branchNameToDisplay = transactionData['branch_name'] ?? transactionData['branch_code'] ?? 'N/A';

    // Logika untuk menampilkan nama pelanggan (jika ada)
    final Map<String, dynamic>? customerDetails = (transactionData['customer_details'] as Map<String, dynamic>?);
    final String customerName = customerDetails?['name'] ?? '';
    // Anda juga bisa mengambil detail pelanggan lain jika perlu, misalnya no HP
    // final String customerPhone = customerDetails?['phone_number'] ?? '';


    return Scaffold(
      appBar: AppBar(
        title: Text('Struk Pembayaran - $invoiceNumber'),
        automaticallyImplyLeading: false, // Tidak ada tombol kembali standar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Semua konten struk dibungkus dalam satu Column utama
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Kop Struk
            Center(
              child: Column(
                children: [
                  const Text('ALFA OPTIK', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  Text(branchNameToDisplay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('Jl. Raya Pulung Kencana No. 123', style: TextStyle(fontSize: 13)), // Ganti dengan alamat sebenarnya
                  const Text('Tubaba, Lampung', style: TextStyle(fontSize: 13)), // Ganti dengan alamat sebenarnya
                  const Text('Telp: (0721) 555-0101', style: TextStyle(fontSize: 13)), // Ganti dengan no telp sebenarnya
                  const SizedBox(height: 10),
                  const Divider(thickness: 1.0),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Informasi Transaksi (Nomor, Tanggal, Pelanggan, Kasir)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('No: $invoiceNumber', style: const TextStyle(fontSize: 13)),
                Text('$transactionDate $transactionTime', style: const TextStyle(fontSize: 13)),
              ],
            ),
            if (customerName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Text('Pelanggan: $customerName', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            // Text('Kasir: ${transactionData['user_id'] ?? 'Kasir Umum'}', style: const TextStyle(fontSize: 13)), // Nanti bisa nama kasir
            const SizedBox(height: 5),
            const Divider(thickness: 1.0),
            const SizedBox(height: 10),

            // Judul Daftar Item
            const Text("RINCIAN PEMBELIAN:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            // Daftar Item
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['product_name'] ?? 'Nama Produk Tidak Ada', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('  ${item['quantity']} x ${formatCurrency((item['price_per_item'] as num?)?.toDouble() ?? 0.0)}', style: const TextStyle(fontSize: 14)),
                          Text(formatCurrency((item['subtotal'] as num?)?.toDouble() ?? 0.0), style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(thickness: 1.0),

            // Bagian Total
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(formatCurrency(totalAmount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Divider(thickness: 2.0, color: Colors.black87), // Pemisah yang lebih tebal

            // Detail Pembayaran
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
              child: Text('Metode Bayar   : ${paymentMethod.toUpperCase()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            if (paymentMethod.toLowerCase() == 'tunai') ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('BAYAR (TUNAI)', style: TextStyle(fontSize: 14)),
                    Text(formatCurrency(amountReceived), style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('KEMBALI', style: TextStyle(fontSize: 14)),
                    Text(formatCurrency(changeAmount), style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
            if ((paymentMethod.toLowerCase() == 'kartu' || paymentMethod.toLowerCase() == 'qris') && referenceNumber.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Text('No. Referensi    : $referenceNumber', style: const TextStyle(fontSize: 14)),
              ),
            if (notes.isNotEmpty) ...[
               const SizedBox(height: 5),
               const Divider(height: 1.0),
               Padding(
                 padding: const EdgeInsets.symmetric(vertical: 3.0),
                 child: Text('Catatan: $notes', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
               ),
            ],
            const SizedBox(height: 25),

            // Ucapan Terima Kasih
            const Center(child: Text('TERIMA KASIH ATAS KUNJUNGAN ANDA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            const SizedBox(height: 4),
            const Center(child: Text('Semoga Lekas Sembuh & Sehat Selalu', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic))),
            const Center(child: Text('Layanan Pelanggan: 0812-XXXX-XXXX', style: TextStyle(fontSize: 13))),
            const SizedBox(height: 30),

            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Cetak'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur cetak struk belum diimplementasikan.')),
                    );
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
            const SizedBox(height: 20), // Padding bawah
          ],
        ),
      ),
    );
  }
}