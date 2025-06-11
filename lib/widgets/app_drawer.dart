// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import '../models/user_session.dart'; // Impor session manager

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // --- HEADER DRAWER DISESUAIKAN ---
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
            ),
            // Tampilkan nama cabang dari sesi
            accountName: Text(
              UserSession.branchName ?? 'Nama Cabang',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            // Tampilkan username dari sesi
            accountEmail: Text('User: ${UserSession.username ?? ''}'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                // Ambil inisial dari nama cabang
                UserSession.branchName?.substring(0, 1) ?? 'A',
                style: const TextStyle(fontSize: 40.0, color: Colors.blueAccent),
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
                  selected: currentRoute == '/pos',
                  selectedTileColor: Colors.blueAccent.withOpacity(0.15),
                  onTap: () {
                    Navigator.pop(context);
                    // Gunakan pushReplacementNamed jika sudah di halaman POS agar tidak menumpuk
                    if (currentRoute != '/pos') {
                      Navigator.pushReplacementNamed(context, '/pos');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Manajemen Stok'),
                  selected: currentRoute == '/stockManagement',
                  selectedTileColor: Colors.blueAccent.withOpacity(0.15),
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != '/stockManagement') {
                       Navigator.pushNamed(context, '/stockManagement');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_box_outlined),
                  title: const Text('Tambah Produk Baru'),
                  selected: currentRoute == '/addProduct',
                  selectedTileColor: Colors.blueAccent.withOpacity(0.15),
                  onTap: () {
                    Navigator.pop(context);
                     if (currentRoute != '/addProduct') {
                      Navigator.pushNamed(context, '/addProduct');
                    }
                  },
                ),
                // --- CONTOH ROLE-BASED ACCESS ---
                // Tampilkan menu Laporan hanya jika rolenya 'Admin Pusat'
                if (UserSession.role == 'Admin Pusat')
                  ListTile(
                    leading: const Icon(Icons.bar_chart_outlined),
                    title: const Text('Laporan Penjualan'),
                    selected: currentRoute == '/reports',
                    selectedTileColor: Colors.blueAccent.withOpacity(0.15),
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != '/reports') {
                        Navigator.pushNamed(context, '/reports');
                      }
                    },
                  ),
                if (UserSession.role == 'Admin Pusat') ...[
                  ListTile(
                    leading: const Icon(Icons.bar_chart_outlined),
                    title: const Text('Laporan Penjualan'),
                    selected: currentRoute == '/reports',
                    // ... (onTap Laporan)
                  ),
                  // --- TAMBAHKAN MENU BARU DI SINI ---
                  ListTile(
                    leading: const Icon(Icons.manage_accounts_outlined),
                    title: const Text('Manajemen Pengguna'),
                    selected: currentRoute == '/userManagement',
                    selectedTileColor: Colors.blueAccent.withOpacity(0.15),
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != '/userManagement') {
                        Navigator.pushNamed(context, '/userManagement');
                      }
                    },
                  ),
                ],  
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Bantuan'),
                  onTap: () {
                    // Logika bantuan tidak berubah
                  },
                ),
                // --- LOGOUT DISESUAIKAN ---
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    // 1. Bersihkan data sesi
                    UserSession.clear();
                    // 2. Arahkan ke halaman login dan hapus semua rute sebelumnya
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                ),
              ],
            ),
          ),
          // Footer tidak berubah
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