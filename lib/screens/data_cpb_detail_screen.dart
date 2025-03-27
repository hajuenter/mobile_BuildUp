import 'package:flutter/material.dart';
import '../models/data_cpb_model.dart';

class DataCpbDetailScreen extends StatelessWidget {
  final DataCPBModel data;

  const DataCpbDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        title: const Text(
          'Detail Data CPB',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Rumah jika tersedia
              if (data.fotoRumah.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    data.fotoRumah,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/default-image.png",
                        height: 200,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // Data Detail
              _buildDetailSection("ID", data.id.toString()),
              _buildDetailSection("Nama", data.nama),
              _buildDetailSection("Alamat", data.alamat),
              _buildDetailSection("NIK", data.nik),
              _buildDetailSection("No KK", data.noKk),
              _buildDetailSection("Pekerjaan", data.pekerjaan),
              _buildDetailSection("Email", data.email),
              _buildDetailSection("Koordinat", data.koordinat),
              _buildDetailSection("Status", data.status),
              _buildDetailSection("Pengecekan", data.pengecekan),
              // _buildDetailSection("Dibuat", data.createdAt.toString()),
              // _buildDetailSection("Diupdate", data.updatedAt.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Divider(), // Garis pemisah antar data
        ],
      ),
    );
  }
}
