import 'package:flutter/material.dart';
import '../models/data_cpb_model.dart';

class UserInfoWidget extends StatelessWidget {
  final DataCPBModel data;

  const UserInfoWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "NAMA: ${data.nama.toUpperCase()}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 8),
        Text(
          "NIK: ${data.nik}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }
}
