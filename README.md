# 📱 NganjukMase Mobile – Aplikasi Verifikasi Data CPB

**NganjukMase Mobile** adalah aplikasi mobile yang digunakan oleh **Petugas Verifikasi Data CPB** untuk melakukan proses survey dan verifikasi calon penerima bantuan rumah tidak layak huni (RTLH) di Kabupaten Nganjuk. Aplikasi ini merupakan bagian dari sistem terintegrasi dengan website **NganjukMase** yang dibangun menggunakan Laravel.

## 🧩 Teknologi yang Digunakan

- **Flutter & Dart** – Framework dan bahasa pemrograman utama untuk pengembangan aplikasi mobile cross-platform.
- **Firebase Authentication** – Untuk manajemen login menggunakan Google Account.
- **RESTful API** – Berkomunikasi dengan backend Laravel untuk mengambil dan mengirim data.
- **Chart Libraries (misal: fl_chart)** – Untuk menampilkan grafik statistik CPB.
- **Provider / Bloc** – Untuk state management (sesuaikan sesuai arsitektur yang dipakai).

## 🎯 Fitur Utama Aplikasi

### 🔐 Autentikasi

- Login dengan Google menggunakan Firebase Auth
- Login dengan email dan password
- Register akun petugas
- Lupa password via OTP melalui gmail

### 👤 Profil Pengguna

- Menampilkan informasi profil petugas
- Edit profil (jika diperlukan)

### 📊 Home Screen

- Menampilkan:
  - Jumlah total data CPB
  - Jumlah data CPB yang sudah diverifikasi
  - Jumlah CPB yang lolos dan tidak lolos seleksi
  - Grafik statistik CPB

### ✅ Verifikasi Data CPB (Fitur Utama)

- Petugas dapat memilih data CPB dari daftar
- Input hasil survei lapangan secara manual
- Sistem akan menghitung otomatis apakah CPB **layak atau tidak layak** menerima bantuan
- Hasil verifikasi tersimpan dan dikirim ke server via API

## 📷 Tampilan Aplikasi

Berikut adalah beberapa tampilan antarmuka dari aplikasi NganjukMase Mobile:

<img src="screenshoot/satu.jpg" width="300" alt="Splash Screen" />

<img src="screenshoot/login.jpg" width="300" alt="Login Screen" />

<img src="screenshoot/daftar.jpg" width="300" alt="Register Screen" />

<img src="screenshoot/lupapas.jpg" width="300" alt="Lupa Password Screen" />

<img src="screenshoot/home.jpg" width="300" alt="Home Screen" />

<img src="screenshoot/verifikasihalaman.jpg" width="300" alt="Verifikasi Data CPB" />

<img src="screenshoot/daftarhalaman.jpg" width="300" alt="Data CPB" />

<img src="screenshoot/detailcpb.jpg" width="300" alt="Detail Data CPB" />

<img src="screenshoot/verif.jpg" width="300" alt="Proses Verifikasi Data CPB" />

<img src="screenshoot/profil.jpg" width="300" alt="Profil Pengguna" />

## 📥 Cara Menjalankan Proyek (untuk Developer)

### Prasyarat

Pastikan Anda sudah menginstal:

- ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) [Flutter SDK](https://flutter.dev/docs/get-started/install)
- ![Dart](https://img.shields.io/badge/Dart-017592?style=for-the-badge&logo=dart&logoColor=white) – Bahasa pemrograman utama Flutter
- ![Android Studio / VS Code](https://img.shields.io/badge/Editor-Android%20Studio%20%2F%20VS%20Code-blue?style=for-the-badge) – IDE pilihan Anda
- ![Firebase Console](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black) – Untuk setup autentikasi Google
