// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// Sesuaikan path import ini dengan struktur folder dan nama proyek Anda
import 'package:alfaoptik/screens/login_page.dart';
import 'package:alfaoptik/screens/pos/pos_page.dart';
import 'package:alfaoptik/screens/inventory/add_product_form.dart';
import 'package:alfaoptik/screens/checkout/checkout_page.dart';
import 'package:alfaoptik/screens/receipt/receipt_page.dart';
import 'package:alfaoptik/screens/reports/reports_page.dart';
import 'package:alfaoptik/screens/inventory/stock_management_page.dart';
import 'package:alfaoptik/screens/inventory/add_stock_page.dart';
import 'package:alfaoptik/screens/admin/user_management_page.dart';
import 'package:alfaoptik/screens/history/transaction_history_page.dart';

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Memuat data lokalisasi untuk Bahasa Indonesia
  await initializeDateFormatting('id_ID', null); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alfa Optik POS',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 2, // Sedikit shadow untuk appbar
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme( // Tema global untuk input field
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      initialRoute: '/login', // Halaman awal aplikasi
      routes: {
        '/login': (context) => const LoginPage(),
        '/pos': (context) => const POSPage(),
        '/stockManagement': (context) => const StockManagementPage(),
        '/addProduct': (context) => const AddProductForm(),
        '/reports': (context) => const ReportsPage(),
        '/userManagement': (context) => const UserManagementPage(),
        '/history': (context) => const TransactionHistoryPage(),
      },
      onGenerateRoute: (settings) {
        // Digunakan untuk rute yang memerlukan argumen atau logika khusus
        if (settings.name == '/checkout') {
          // Ekstrak argumen yang dikirim dari POSPage
          final args = settings.arguments as Map<String, dynamic>?;

          if (args != null &&
              args['cartItems'] is List<CartItem> && // Pastikan CartItem bisa diakses/diimpor
              args['totalAmount'] is double) {
            return MaterialPageRoute(
              builder: (context) {
                return CheckoutPage(
                  cartItems: args['cartItems'] as List<CartItem>,
                  totalAmount: args['totalAmount'] as double,
                );
              },
            );
          }
          // Jika argumen tidak sesuai atau tidak ada, arahkan ke halaman error argumen
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Kesalahan Navigasi")),
              body: const Center(
                child: Text('Error: Argumen untuk halaman checkout tidak valid atau tidak ditemukan.'),
              ),
            ),
          );
        } else if (settings.name == '/receipt') { // <-- TAMBAHKAN PENANGANAN UNTUK RUTE /receipt
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null) { // Di sini kita asumsikan args adalah transactionData Map
            return MaterialPageRoute(
              builder: (context) {
                return ReceiptPage(transactionData: args);
              },
            );
          }
          // Jika argumen tidak sesuai
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text("Kesalahan Navigasi")),
              body: const Center(
                child: Text('Error: Argumen untuk halaman struk tidak valid atau tidak ditemukan.'),
              ),
            ),
          );
        }

        // Jika rute tidak dikenal dan tidak ditangani di atas atau di 'routes' map
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text("Halaman Tidak Ditemukan")),
            body: Center(
              child: Text('Error 404: Rute "${settings.name}" tidak ditemukan.'),
            ),
          ),
        );
      },
    );
  }
}