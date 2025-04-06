class VerifikasiModel {
  final String nik;
  final String fotoKK;
  final String fotoKTP;
  final bool kesanggupanBerswadaya;
  final String tipe;

  // Kondisi bangunan (0.0 - 1.0)
  final double penutupAtap;
  final double rangkaAtap;
  final double kolom;
  final double ringBalok;
  final double dindingPengisi;
  final double kusen;
  final double pintu;
  final double jendela;
  final double strukturBawah;
  final double penutupLantai;
  final double pondasi;
  final double sloof;
  final double mck;
  final double airKotor;

  // Foto-foto bangunan

  final String fotoPenutupAtap;
  final String fotoRangkaAtap;
  final String fotoKolom;
  final String fotoRingBalok;
  final String fotoDindingPengisi;
  final String fotoKusen;
  final String fotoPintu;
  final String fotoJendela;
  final String fotoStrukturBawah;
  final String fotoPenutupLantai;
  final String fotoPondasi;
  final String fotoSloof;
  final String fotoMck;
  final String fotoAirKotor;

  VerifikasiModel({
    required this.fotoKK,
    required this.fotoKTP,
    required this.nik,
    required this.kesanggupanBerswadaya,
    required this.tipe,
    required this.penutupAtap,
    required this.rangkaAtap,
    required this.kolom,
    required this.ringBalok,
    required this.dindingPengisi,
    required this.kusen,
    required this.pintu,
    required this.jendela,
    required this.strukturBawah,
    required this.penutupLantai,
    required this.pondasi,
    required this.sloof,
    required this.mck,
    required this.airKotor,
    required this.fotoPenutupAtap,
    required this.fotoRangkaAtap,
    required this.fotoKolom,
    required this.fotoRingBalok,
    required this.fotoDindingPengisi,
    required this.fotoKusen,
    required this.fotoPintu,
    required this.fotoJendela,
    required this.fotoStrukturBawah,
    required this.fotoPenutupLantai,
    required this.fotoPondasi,
    required this.fotoSloof,
    required this.fotoMck,
    required this.fotoAirKotor,
  });

  factory VerifikasiModel.fromJson(Map<String, dynamic> json) {
    return VerifikasiModel(
      fotoKK: json['foto_kk'] ?? '',
      fotoKTP: json['foto_ktp'] ?? '',
      nik: json['nik'] ?? '',
      kesanggupanBerswadaya: json['kesanggupan_berswadaya'] == 1,
      tipe: json['tipe'] ?? '',
      penutupAtap: _parseDouble(json['penutup_atap']),
      rangkaAtap: _parseDouble(json['rangka_atap']),
      kolom: _parseDouble(json['kolom']),
      ringBalok: _parseDouble(json['ring_balok']),
      dindingPengisi: _parseDouble(json['dinding_pengisi']),
      kusen: _parseDouble(json['kusen']),
      pintu: _parseDouble(json['pintu']),
      jendela: _parseDouble(json['jendela']),
      strukturBawah: _parseDouble(json['struktur_bawah']),
      penutupLantai: _parseDouble(json['penutup_lantai']),
      pondasi: _parseDouble(json['pondasi']),
      sloof: _parseDouble(json['sloof']),
      mck: _parseDouble(json['mck']),
      airKotor: _parseDouble(json['air_kotor']),
      fotoPenutupAtap: json['foto_penutup_atap'] ?? '',
      fotoRangkaAtap: json['foto_rangka_atap'] ?? '',
      fotoKolom: json['foto_kolom'] ?? '',
      fotoRingBalok: json['foto_ring_balok'] ?? '',
      fotoDindingPengisi: json['foto_dinding_pengisi'] ?? '',
      fotoKusen: json['foto_kusen'] ?? '',
      fotoPintu: json['foto_pintu'] ?? '',
      fotoJendela: json['foto_jendela'] ?? '',
      fotoStrukturBawah: json['foto_struktur_bawah'] ?? '',
      fotoPenutupLantai: json['foto_penutup_lantai'] ?? '',
      fotoPondasi: json['foto_pondasi'] ?? '',
      fotoSloof: json['foto_sloof'] ?? '',
      fotoMck: json['foto_mck'] ?? '',
      fotoAirKotor: json['foto_air_kotor'] ?? '',
    );
  }
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }
}
