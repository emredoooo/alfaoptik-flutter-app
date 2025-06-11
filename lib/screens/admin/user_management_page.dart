// lib/screens/admin/user_management_page.dart
import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import 'user_form_page.dart'; // <-- IMPOR FORM PAGE BARU

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final UserService _userService = UserService();
  late Future<List<dynamic>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUserList();
  }

  void _refreshUserList() {
    setState(() {
      _usersFuture = _userService.getUsers();
    });
  }

  void _navigateAndRefresh(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    // Jika kembali dengan nilai 'true', refresh daftar
    if (result == true) {
      _refreshUserList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data pengguna.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user['role'] == 'Admin Pusat' ? 'AP' : 'AC'),
                  ),
                  title: Text(user['full_name'] ?? 'Nama Tidak Ada'),
                  subtitle: Text(
                    'Username: ${user['username']} | Role: ${user['role']}\n'
                    'Cabang: ${user['branch_name'] ?? 'Pusat'}',
                  ),
                  isThreeLine: true,
                  // --- TOMBOL EDIT DITAMBAHKAN DI SINI ---
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit Pengguna',
                    onPressed: () {
                      // Navigasi ke form dalam mode Edit
                      _navigateAndRefresh(UserFormPage(user: user));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigasi ke form dalam mode Tambah
          _navigateAndRefresh(UserFormPage());
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Karyawan'),
      ),
    );
  }
}