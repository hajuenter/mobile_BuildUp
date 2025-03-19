import '../services/api_service.dart';

class DataCPBModel {
  final int id;
  final String nama;
  final String alamat;
  final String nik;
  final String noKk;
  final String pekerjaan;
  final String email;
  final String fotoRumah;
  final String koordinat;
  final String status;
  final String pengecekan;
  final DateTime createdAt;
  final DateTime updatedAt;

  DataCPBModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.nik,
    required this.noKk,
    required this.pekerjaan,
    required this.email,
    required this.fotoRumah,
    required this.koordinat,
    required this.status,
    required this.pengecekan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DataCPBModel.fromJson(Map<String, dynamic> json) {
    return DataCPBModel(
      id: json['id'],
      nama: json['nama'],
      alamat: json['alamat'],
      nik: json['nik'],
      noKk: json['no_kk'],
      pekerjaan: json['pekerjaan'],
      email: json['email'],
      fotoRumah: json['foto_rumah'] != null && json['foto_rumah'].isNotEmpty
          ? "${ApiService.baseImageUrlCPB}${json['foto_rumah']}"
          : "${ApiService.baseImageUrlCPB}up/data_cpb/default-cpb.png",
      koordinat: json['koordinat'],
      status: json['status'],
      pengecekan: json['pengecekan'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
