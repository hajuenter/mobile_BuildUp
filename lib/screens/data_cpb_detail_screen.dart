import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart'; // Tambahkan package ini
import '../models/data_cpb_model.dart';

class DataCpbDetailScreen extends StatefulWidget {
  final DataCPBModel data;

  const DataCpbDetailScreen({super.key, required this.data});

  @override
  State<DataCpbDetailScreen> createState() => _DataCpbDetailScreenState();
}

class _DataCpbDetailScreenState extends State<DataCpbDetailScreen> {
  final MapController _mapController = MapController();

  // Mendapatkan LatLng dari string koordinat
  LatLng? _getLatLngFromString() {
    try {
      final koordinatParts = widget.data.koordinat.split(',');
      if (koordinatParts.length == 2) {
        final latitude = double.parse(koordinatParts[0].trim());
        final longitude = double.parse(koordinatParts[1].trim());

        // Pastikan nilai koordinat valid
        if (latitude.isFinite && longitude.isFinite) {
          return LatLng(latitude, longitude);
        }
      }
    } catch (e) {
      debugPrint('Error parsing koordinat: $e');
    }
    return null;
  }

  // Fungsi untuk membuka Google Maps
  void _openGoogleMaps(LatLng coordinates) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${coordinates.latitude},${coordinates.longitude}',
    );

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Gagal membuka Google Maps: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka Google Maps: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final latLng = _getLatLngFromString();

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
              if (widget.data.fotoRumah.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.data.fotoRumah,
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

              // Peta OpenStreetMap via flutter_map
              if (latLng != null)
                Column(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: latLng,
                            initialZoom: 15.0, // Gunakan zoom level tetap
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point: latLng,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tambahkan tombol untuk pergi ke Google Maps
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _openGoogleMaps(latLng),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D6EFD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Klik disini untuk pergi ke Maps',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // Data Detail
              _buildDetailSection("ID", widget.data.id.toString()),
              _buildDetailSection("Nama", widget.data.nama),
              _buildDetailSection("Alamat", widget.data.alamat),
              _buildDetailSection("NIK", widget.data.nik),
              _buildDetailSection("No KK", widget.data.noKk),
              _buildDetailSection("Pekerjaan", widget.data.pekerjaan),
              _buildDetailSection("Email", widget.data.email),
              _buildDetailSection("Koordinat", widget.data.koordinat),
              _buildDetailSection("Status", widget.data.status),
              _buildDetailSection("Pengecekan", widget.data.pengecekan),
              // _buildDetailSection("Dibuat", widget.data.createdAt.toString()),
              // _buildDetailSection("Diupdate", widget.data.updatedAt.toString()),
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
