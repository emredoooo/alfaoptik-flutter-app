// lib/models/user_session.dart

class UserSession {

  // Properti untuk menyimpan data pengguna yang sedang login.
  static int? userId;
  static String? username;
  static String? role;
  static String? branchCode;
  static String? branchName;

  /// Method untuk mengisi data sesi saat login berhasil.
  /// Menerima sebuah Map yang berisi data dari API.
  static void setData(Map<String, dynamic> userData) {
    // --- PERBAIKAN KUNCI DI SINI ---
    userId = userData['user_id'];       // diganti dari 'userId'
    username = userData['username'];
    role = userData['role'];
    branchCode = userData['branch_code']; // diganti dari 'branchCode'
    branchName = userData['branch_name']; // diganti dari 'branchName'
    // -------------------------

    print('--- Sesi Disimpan: branchCode = ${UserSession.branchCode} ---');
  }

  /// Method untuk membersihkan data sesi saat pengguna logout.
  static void clear() {
    userId = null;
    username = null;
    role = null;
    branchCode = null;
    branchName = null;
  }
}