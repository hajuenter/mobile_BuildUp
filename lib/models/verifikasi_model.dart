class VerifikasiModel {
  final String nik;
  final double penilaianKerusakan;
  final int nilaiBantuan;
  final String catatan;

  VerifikasiModel({
    required this.nik,
    required this.penilaianKerusakan,
    required this.nilaiBantuan,
    required this.catatan,
  });

  factory VerifikasiModel.fromJson(Map<String, dynamic> json) {
    return VerifikasiModel(
      nik: json['nik'],
      penilaianKerusakan: (json['penilaian_kerusakan'] as num).toDouble(),
      nilaiBantuan: json['nilai_bantuan'],
      catatan: json['catatan'],
    );
  }
}
