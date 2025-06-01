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

<div style="display: flex; flex-wrap: wrap; gap: 16px;">
  <div style="flex: 1 1 200px;">
    <img src="screenshoot/satu.jpg" width="250" alt="Splash Screen" />
    <p><em>Splash Screen</em></p>
  </div>
  <div style="flex: 1 1 200px;">
    <img src="screenshoot/login.jpg" width="250" alt="Login Screen" />
    <p><em>Login Screen</em></p>
  </div>
  <div style="flex: 1 1 200px;">
    <img src="screenshoot/daftar.jpg" width="250" alt="Register Screen" />
    <p><em>Register Screen</em></p>
  </div>
  <div style="flex: 1 1 200px;">
    <img src="screenshoot/lupapas.jpg" width="250" alt="Lupa Password Screen" />
    <p><em>Lupa Password Screen</em></p>
  </div>
  <div style="flex: 1 1 200px;">
    <img src="screenshoot/home.jpg" width="250" alt="Home Screen" />
    <p><em>Home Screen</em></p>
  </div>
  <div style="flex: 1 1 200px;">
    <img src="screenshoot/verifikasihalaman.jpg" width="250" alt="Verifikasi Data CPB" />
    <p><em>Verifikasi Data CPB</em></p>
  </div>
  <div style="flex: 1 1 200px;">
    <img src="screenshoot/daftarhalaman.jpg" width="250" alt="Data CPB" />
    <p><em>Data CPB</em></p>
  </div>
  <div style="flex: 1 1 200px;">
    <img src="screenshoot/detailcpb.jpg" width="250" alt="Detail Data CPB" />
    <p><em>Detail Data CPB</em></p>
  </div>
  <div style="flex: 1 1 200px;">
    <img src="screenshoot/verif.jpg" width="250" alt="Proses Verifikasi Data CPB" />
    <p><em>Proses Verifikasi Data CPB</em></p>
  </div>
  <div style="flex: 1 1 200px;">
    <img src="screenshoot/profil.jpg" width="250" alt="Profil Pengguna" />
    <p><em>Profil Pengguna</em></p>
  </div>
</div>

## 📥 Cara Menjalankan Proyek (untuk Developer)

### Prasyarat

Pastikan Anda sudah menginstal:

- ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) – Framework Flutter
- ![Dart](https://img.shields.io/badge/Dart-017592?style=for-the-badge&logo=dart&logoColor=white) – Bahasa pemrograman utama Flutter
- ![Android Studio / VS Code](https://img.shields.io/badge/Editor-Android%20Studio%20%2F%20VS%20Code-blue?style=for-the-badge) – IDE pilihan Anda
- ![Firebase Console](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black) – Untuk setup autentikasi Google
