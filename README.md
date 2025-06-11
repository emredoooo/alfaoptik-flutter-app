# Alfa Optik - Aplikasi Point of Sale (POS)

Selamat datang di repositori proyek Alfa Optik POS. Proyek ini adalah aplikasi Point of Sale (POS) lintas platform yang dibangun untuk memenuhi kebutuhan manajemen optik modern, mulai dari transaksi, inventaris, hingga manajemen pengguna.

## Daftar Isi

- [Fitur Utama](#fitur-utama)
- [Tumpukan Teknologi (Tech Stack)](#tumpukan-teknologi-tech-stack)
- [Struktur Proyek](#struktur-proyek)
- [Prasyarat](#prasyarat)
- [Panduan Instalasi](#panduan-instalasi)
  - [Backend (Node.js)](#backend-nodejs)
  - [Frontend (Flutter)](#frontend-flutter)
- [Daftar Endpoint API](#daftar-endpoint-api)

## Fitur Utama

Berikut adalah fitur-fitur yang sudah dan sedang dikembangkan dalam aplikasi ini:

- **Transaksi & POS**:
  - Proses penjualan yang intuitif.
  - Pencarian produk dan pemindai barcode.
  - Manajemen keranjang belanja dinamis.
  - Dukungan berbagai metode pembayaran (Tunai, Kartu, QRIS).
  - Perhitungan kembalian otomatis.
  - Pembuatan dan pencetakan struk (PDF).

- **Manajemen Inventaris**:
  - Menampilkan daftar produk beserta stoknya.
  - Penambahan produk baru ke dalam sistem.
  - Penambahan stok untuk produk yang sudah ada.
  - Antarmuka yang efisien untuk menambah stok langsung dari daftar produk.

- **Manajemen Pengguna & Cabang**:
  - Sistem login untuk autentikasi pengguna.
  - Tampilan dan data yang disesuaikan berdasarkan cabang pengguna yang login.
  - Hak akses berbasis peran (Admin Pusat & Admin Cabang).
  - Fitur manajemen pengguna (tambah & edit) khusus untuk Admin Pusat.

- **Manajemen Pelanggan**:
  - Pencarian pelanggan berdasarkan nomor telepon.
  - Pendaftaran pelanggan baru saat proses transaksi.

- **Pelaporan**:
  - (*Dalam Pengembangan*) Halaman laporan penjualan.

## Tumpukan Teknologi (Tech Stack)

- **Frontend**: Flutter
- **Backend**: Node.js dengan framework Express.js
- **Database**: MySQL
- **Manajemen Dependensi**:
  - Frontend: `pub`
  - Backend: `npm`

## Struktur Proyek

Proyek ini dibagi menjadi dua bagian utama: backend dan frontend.

```
/
├── alfaoptik-backend/      # Folder untuk server Node.js
│   ├── server.js
│   ├── database.sql
│   └── package.json
│
└── alfaoptik-flutter-app/  # Folder untuk aplikasi Flutter
    ├── lib/
    │   ├── models/         # (Struktur Data, contoh: Customer)
    │   │   └── customer_model.dart
    │   │
    │   ├── screens/        # (Halaman-halaman utama aplikasi)
    │   │   ├── admin/
    │   │   │   ├── user_form_page.dart
    │   │   │   └── user_management_page.dart
    │   │   ├── checkout/
    │   │   ├── inventory/
    │   │   ├── pos/
    │   │   ├── receipt/
    │   │   ├── reports/
    │   │   └── scanner/
    │   │
    │   ├── services/       # (Logika untuk komunikasi dengan API)
    │   │   ├── auth_service.dart
    │   │   ├── product_service.dart
    │   │   └── ...
    │   │
    │   ├── widgets/        # (Komponen UI yang dapat digunakan kembali)
    │   │   └── app_drawer.dart
    │   │
    │   ├── main.dart       # (Titik awal aplikasi Flutter)
    │   └── user_session.dart # (Pengelola sesi login)
    │
    └── pubspec.yaml
```

## Prasyarat

Pastikan perangkat Anda sudah terinstal:
- [Node.js](https://nodejs.org/) (disarankan versi LTS)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Server Database MySQL (seperti XAMPP, Laragon, atau instalasi mandiri)
- `nodemon` (opsional, untuk auto-restart server): `npm install -g nodemon`

## Panduan Instalasi
## Repositori Backend

Kode untuk server API (Node.js) untuk proyek ini berada di repositori terpisah. Kunjungi di sini:

➡️ **[emredoooo/alfaoptik-backend](https://github.com/emredoooo/alfaoptik-backend)**
### Backend (Node.js)

1.  **Navigasi ke Folder Backend**:
    ```bash
    cd alfaoptik-backend
    ```

2.  **Install Dependensi**:
    ```bash
    npm install
    ```
    Perintah ini akan menginstal `express`, `mysql2`, `cors`, dan `bcryptjs`.

3.  **Setup Database**:
    - Buat sebuah database baru di MySQL Anda dengan nama `ao_db`.
    - Jalankan semua query SQL dari file `database.sql` untuk membuat semua tabel yang dibutuhkan.

4.  **Jalankan Server**:
    ```bash
    node server.js
    ```
    Atau jika menggunakan `nodemon`:
    ```bash
    nodemon server.js
    ```
    Server akan berjalan di `http://localhost:3000`.

### Frontend (Flutter)

1.  **Buka Proyek**: Buka folder `alfaoptik-flutter-app` dengan code editor Anda (seperti VS Code).

2.  **Install Dependensi Flutter**:
    ```bash
    flutter pub get
    ```

3.  **Jalankan Aplikasi**:
    - Pastikan backend sudah berjalan.
    - Jalankan aplikasi pada emulator atau perangkat yang Anda inginkan.
    ```bash
    flutter run
    ```

## Daftar Endpoint API

Berikut adalah daftar endpoint API yang telah dibuat di `server.js`:

| Metode | Endpoint                        | Deskripsi                               |
| :----- | :-----------------------------  | :-------------------------------------- |
| `POST` | `/api/auth/login`               | Melakukan login pengguna.               |
| `POST` | `/api/users`                    | Membuat pengguna (karyawan) baru.       |
| `GET`  | `/api/users`                    | Mengambil daftar semua pengguna.        |
| `PUT`  | `/api/users/:userId`            | Memperbarui data pengguna.              |
| `GET`  | `/api/branches`                 | Mengambil daftar semua cabang.          |
| `GET`  | `/api/products`                 | Mengambil produk berdasarkan cabang.    |
| `POST` | `/api/products`                 | Menambah produk baru.                   |
| `PATCH`| `/api/products/:productId/stock`| Menambah stok pada produk tertentu.     |
| `POST` | `/api/transactions`             | Menyimpan transaksi baru.               |
| `GET`  | `/api/customers/phone/:phone`   | Mencari pelanggan via nomor telepon.    |
| `GET`  | `/api/reports/sales`            | Mengambil data laporan penjualan.       |

---
Dibuat dengan kesadaran penuh, namun tiada yang sempurna kecuali "NYA". //em
