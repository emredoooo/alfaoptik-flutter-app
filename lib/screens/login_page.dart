// lib/screens/login_page.dart (Mengembalikan Navigasi)
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() { // Mengganti nama fungsi kembali ke _login (opsional)
    if (_formKey.currentState!.validate()) {
      // Form valid, lanjutkan dengan logika "login"
      // Untuk saat ini, kita anggap login selalu berhasil dan langsung navigasi
      print('Form valid. Melakukan navigasi...');
      print('Username: ${_usernameController.text}');
      print('Password: ${_passwordController.text}');

      // KEMBALIKAN NAVIGASI INI:
      Navigator.pushReplacementNamed(context, '/pos');

    } else {
      print('Form tidak valid.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Anda bisa mengembalikan judul aslinya jika mau
        title: const Text('Login - Alfa Optik POS'),
        // automaticallyImplyLeading: false, // Jika Anda tidak ingin tombol kembali
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Anda bisa mengembalikan UI asli LoginPage jika mau,
                  // seperti Text('Selamat Datang!') dll.
                   const Text(
                    'Login Aplikasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _login, // Panggil fungsi _login
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text('Login'), // Kembalikan teks tombol
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}