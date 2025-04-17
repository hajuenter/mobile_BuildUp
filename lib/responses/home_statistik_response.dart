import '../models/statistik_data_model.dart';

class HomeStatistikResponse {
  final bool status;
  final String message;
  final StatistikDataModel data;

  HomeStatistikResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory HomeStatistikResponse.fromJson(Map<String, dynamic> json) {
    return HomeStatistikResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: StatistikDataModel.fromJson(json['data'] ?? {}),
    );
  }
}
