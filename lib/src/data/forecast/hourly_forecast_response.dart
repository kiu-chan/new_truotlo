// lib/src/data/forecast/hourly_forecast_response.dart

import 'package:new_truotlo/src/data/forecast/hourly_forecast_point.dart';

class HourlyForecastResponse {
  final bool success;
  final Map<String, List<HourlyForecastPoint>> data;
  final Map<String, dynamic> filters;
  final int totalPoints;
  final String currentTime;

  HourlyForecastResponse({
    required this.success,
    required this.data,
    required this.filters,
    required this.totalPoints,
    required this.currentTime,
  });

  factory HourlyForecastResponse.fromJson(Map<String, dynamic> json) {
    // Khởi tạo map data rỗng
    Map<String, List<HourlyForecastPoint>> parsedData = {};
    
    // Xử lý dữ liệu data
    if (json['data'] != null) {
      final rawData = json['data'] as Map<String, dynamic>;
      rawData.forEach((key, value) {
        if (value is List) {
          parsedData[key] = value
              .map((item) => HourlyForecastPoint.fromJson(item))
              .toList();
        }
      });
    }

    return HourlyForecastResponse(
      success: json['success'] ?? false,
      data: parsedData,
      filters: json['filters'] ?? {},
      totalPoints: json['total_points'] ?? 0,
      currentTime: json['current_time'] ?? '',
    );
  }
}