// lib/models/customer_model.dart (Contoh)
class Customer {
  final String? id; // ID bisa null jika pelanggan baru belum disimpan ke DB
  final String name;
  final String phoneNumber;
  final String? address;
  final DateTime? dateOfBirth; // Atau String jika Anda lebih suka

  Customer({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.address,
    this.dateOfBirth,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String?, // Ambil ID sebagai string
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
    );
  }
}