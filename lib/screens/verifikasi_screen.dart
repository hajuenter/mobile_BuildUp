import 'package:flutter/material.dart';
import '../models/data_cpb_model.dart';

class VerifikasiScreen extends StatefulWidget {
  final DataCPBModel data; // Terima data CPB

  const VerifikasiScreen({super.key, required this.data});

  @override
  State<VerifikasiScreen> createState() => _VerifikasiScreenState();
}

class _VerifikasiScreenState extends State<VerifikasiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D6EFD), // Warna biru sesuai permintaan
        title: Text(
          'Form Verifikasi',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white), // Tombol kembali putih
          onPressed: () =>
              Navigator.pop(context), // Kembali ke halaman sebelumnya
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama
            Text(
              "Nama: ${widget.data.nama}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // NIK
            Text("NIK: ${widget.data.nik}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),

            // Alamat
            Text("Alamat: ${widget.data.alamat}",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),

            // Pekerjaan
            Text("Pekerjaan: ${widget.data.pekerjaan}",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),

            // Status
            Text(
              "Status: ${widget.data.status}",
              style: TextStyle(
                fontSize: 16,
                color: widget.data.status == "Terverifikasi"
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            SizedBox(height: 8),

            // Pengecekan
            Text(
              "Pengecekan: ${widget.data.pengecekan}",
              style: TextStyle(
                fontSize: 16,
                color: widget.data.pengecekan == "Sudah Dicek"
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            SizedBox(height: 16),

            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implementasi konfirmasi verifikasi
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Verifikasi"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implementasi tolak verifikasi
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Tolak"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
