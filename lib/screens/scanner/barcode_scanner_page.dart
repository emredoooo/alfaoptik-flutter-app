// lib/screens/scanner/barcode_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanCompleted = false;

  // --- KITA KELOLA STATE SECARA MANUAL DI SINI ---
  bool isTorchOn = false;
  bool isFrontCamera = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai Barcode'),
        actions: [
          // --- Tombol Senter (Flash) dengan logika manual ---
          IconButton(
            color: isTorchOn ? Colors.yellow : Colors.white,
            icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: 'Senter',
            onPressed: () async {
              await controller.toggleTorch();
              setState(() {
                // Perbarui state lokal kita setelah mengubah senter
                isTorchOn = !isTorchOn;
              });
            },
          ),
          // --- Tombol Ganti Kamera dengan logika manual ---
          IconButton(
            icon: Icon(isFrontCamera ? Icons.camera_front : Icons.camera_rear),
            tooltip: 'Ganti Kamera',
            onPressed: () async {
              await controller.switchCamera();
              setState(() {
                // Perbarui state lokal kita setelah mengubah kamera
                isFrontCamera = !isFrontCamera;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (!isScanCompleted) {
                final String? code = capture.barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  isScanCompleted = true;
                  print("Barcode ditemukan: $code");
                  // Kirim hasil scan kembali ke halaman sebelumnya (POSPage)
                  Navigator.pop(context, code);
                }
              }
            },
          ),
          // UI Overlay (Kotak Scan)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade400, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}