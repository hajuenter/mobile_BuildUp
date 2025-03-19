import '../models/data_cpb_model.dart';

class DataCPBResponse {
  final bool status;
  final String message;
  final List<DataCPBModel> data;

  DataCPBResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DataCPBResponse.fromJson(Map<String, dynamic> json) {
    return DataCPBResponse(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => DataCPBModel.fromJson(item))
          .toList(),
    );
  }
}
