// lib/screens/admin/user_form_page.dart
import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class UserFormPage extends StatefulWidget {
  // Terima data user opsional. Jika tidak null, berarti ini mode Edit.
  final Map<String, dynamic>? user;

  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  
  // Controllers untuk form
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedRole;
  int? _selectedBranchId;
  bool _isEditMode = false;
  bool _isLoading = false;

  List<dynamic> _branches = [];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.user != null;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Ambil daftar cabang untuk dropdown
    try {
      final branchesData = await _userService.getBranches();
      setState(() {
        _branches = branchesData;
      });
    } catch (e) {
      // Tangani error
    }

    // Jika ini mode Edit, isi form dengan data yang ada
    if (_isEditMode) {
      _usernameController.text = widget.user!['username'];
      _fullNameController.text = widget.user!['full_name'];
      _selectedRole = widget.user!['role'];
      // Cari branch_id dari user di daftar branches
      final userBranchName = widget.user!['branch_name'];
      if (userBranchName != null) {
        final branch = _branches.firstWhere((b) => b['branch_name'] == userBranchName, orElse: () => null);
        if (branch != null) {
          _selectedBranchId = branch['branch_id'];
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      try {
        if (_isEditMode) {
          // --- LOGIKA UNTUK EDIT ---
          final userData = {
            'full_name': _fullNameController.text,
            'role': _selectedRole,
            'branch_id': _selectedRole == 'Admin Cabang' ? _selectedBranchId : null,
          };
          await _userService.updateUser(widget.user!['user_id'], userData);
        } else {
          // --- LOGIKA UNTUK TAMBAH BARU ---
          final userData = {
            'username': _usernameController.text,
            'password': _passwordController.text,
            'full_name': _fullNameController.text,
            'role': _selectedRole,
            'branch_id': _selectedRole == 'Admin Cabang' ? _selectedBranchId : null,
          };
          await _userService.createUser(userData);
        }

        if (mounted) {
          final message = _isEditMode ? 'Data berhasil diperbarui!' : 'Pengguna baru berhasil dibuat!';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          Navigator.of(context).pop(true); // Kirim 'true' untuk menandakan ada update
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Pengguna' : 'Tambah Pengguna Baru'),
      ),
      body: _branches.isEmpty && !_isEditMode
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                      validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      // Username hanya bisa diisi saat mode Tambah
                      enabled: !_isEditMode,
                      validator: (v) => v!.isEmpty && !_isEditMode ? 'Username tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    // Password hanya wajib saat mode Tambah
                    if (!_isEditMode)
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (v) => v!.isEmpty && !_isEditMode ? 'Password tidak boleh kosong' : null,
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Peran (Role)'),
                      items: ['Admin Pusat', 'Admin Cabang']
                          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedRole = value),
                      validator: (v) => v == null ? 'Pilih peran' : null,
                    ),
                    const SizedBox(height: 16),
                    // Tampilkan dropdown cabang jika rolenya Admin Cabang
                    if (_selectedRole == 'Admin Cabang')
                      DropdownButtonFormField<int>(
                        value: _selectedBranchId,
                        decoration: const InputDecoration(labelText: 'Cabang'),
                        items: _branches
                            .map((branch) => DropdownMenuItem(
                                value: branch['branch_id'] as int,
                                child: Text(branch['branch_name'])))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedBranchId = value),
                        validator: (v) => v == null ? 'Pilih cabang' : null,
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) 
                          : const Text('Simpan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}