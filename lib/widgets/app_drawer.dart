// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan nama rute dari halaman yang sedang aktif
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            padding: EdgeInsets.only(bottom: 20, left: 16),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Alfa Optik',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.point_of_sale_outlined),
                  title: const Text('Point of Sale (POS)'),
                  // Tandai sebagai terpilih jika rute saat ini adalah '/pos'
                  selected: currentRoute == '/pos',
                  selectedTileColor: Colors.blueAccent.withOpacity(0.15),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/pos');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Manajemen Stok'), // Ganti nama menu
                  selected: currentRoute == '/stockManagement', // Sesuaikan nama rute
                  selectedTileColor: Colors.blueAccent.withOpacity(0.15),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/stockManagement'); // Arahkan ke rute baru
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_box_outlined),
                  title: const Text('Tambah Produk Baru'),
                   // Tandai sebagai terpilih jika rute saat ini adalah '/addProduct'
                  selected: currentRoute == '/addProduct',
                  selectedTileColor: Colors.blueAccent.withOpacity(0.15),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/addProduct');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart_outlined),
                  title: const Text('Laporan Penjualan'),
                  // Tandai sebagai terpilih jika rute saat ini adalah '/reports'
                  selected: currentRoute == '/reports',
                  selectedTileColor: Colors.blueAccent.withOpacity(0.15),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/reports');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Bantuan'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Bantuan'),
                        content: const Text('silahkan hubungi:\n'
                            'emredo - 082211234557\nuntuk bantuan lebih lanjut.'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK'),
                          )
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'dibuat dengan cinta <3\nc${DateTime.now().year} //emredo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}