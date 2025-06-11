// lib/user_session.dart

// Kelas statis untuk menyimpan informasi sesi pengguna secara global.
// 'static' berarti kita tidak perlu membuat instance dari kelas ini untuk mengakses datanya.
// Kita bisa langsung memanggil UserSession.userId, UserSession.setData(), dll.
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
    userId = userData['userId'];
    username = userData['username'];
    role = userData['role'];
    branchCode = userData['branchCode'];
    branchName = userData['branchName'];
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