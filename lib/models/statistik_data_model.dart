class StatistikDataModel {
  final int prosesVerifikasi;
  final int terverifikasi;
  final int masihLayakHuni;
  final int pengajuan;

  StatistikDataModel({
    required this.prosesVerifikasi,
    required this.terverifikasi,
    required this.masihLayakHuni,
    required this.pengajuan,
  });

  factory StatistikDataModel.fromJson(Map<String, dynamic> json) {
    return StatistikDataModel(
      prosesVerifikasi: json['proses_verifikasi'] ?? 0,
      terverifikasi: json['terverifikasi'] ?? 0,
      masihLayakHuni: json['masih_layak_huni'] ?? 0,
      pengajuan: json['pengajuan'] ?? 0,
    );
  }
}
