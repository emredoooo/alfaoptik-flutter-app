import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Fungsi untuk logout (simulasi)
  void _logout(BuildContext context) {
    // TODO: Implementasi logika logout sebenarnya
    // (hapus sesi pengguna, dll.)
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Di sini Anda akan menampilkan data/menu berbeda
    // berdasarkan peran pengguna (Admin Pusat / Admin Cabang)
    // Untuk saat ini, kita buat generik.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Alfa Optik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer( // Contoh penggunaan Drawer untuk navigasi
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Text(
                'Menu Navigasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale_outlined),
              title: const Text('Point of Sale (POS)'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                // Navigator.pushNamed(context, '/pos'); // Navigasi ke halaman POS
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigasi ke Halaman POS (belum dibuat)')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Manajemen Inventaris'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                // Navigator.pushNamed(context, '/inventoryList'); // Navigasi ke daftar inventaris
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigasi ke Daftar Inventaris (belum dibuat)')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box_outlined),
              title: const Text('Tambah Produk Baru'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.pushNamed(context, '/addProduct');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment_outlined),
              title: const Text('Laporan'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.pushNamed(context, '/reports'); // Navigasi ke halaman laporan
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigasi ke Halaman Laporan (belum dibuat)')),
                );
              },
            ),
            // Tambahkan menu lain sesuai kebutuhan
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Selamat Datang di Alfa Optik POS!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Di sini bisa ditampilkan ringkasan data penting
              // atau tombol aksi cepat
              ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Mulai Transaksi POS'),
                onPressed: () {
                  Navigator.pushNamed(context, '/pos');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur POS belum diimplementasikan')),
                  );
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Tambah Produk Baru'),
                onPressed: () {
                  Navigator.pushNamed(context, '/addProduct');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}