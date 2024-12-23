// lib/src/utils/map_markers.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:new_truotlo/src/data/map/landslide_point.dart';
import 'package:new_truotlo/src/data/forecast/hourly_forecast_response.dart';
import 'package:new_truotlo/src/data/forecast/hourly_forecast_point.dart';

class MapMarkersHandler {
  /// Xác định mức độ nguy cơ từ giá trị số
  static int _getRiskLevel(double value) {
    if (value <= 0) return 0;  // Mặc định
    if (value < 2) return 1;   // Rất thấp (>0 đến <2)
    if (value < 3) return 2;   // Thấp (>=2 đến <3)
    if (value < 4) return 3;   // Trung bình (>=3 đến <4)
    if (value < 5) return 4;   // Cao (>=4 đến <5)
    return 5;                  // Rất cao (>=5)
  }

  /// Lấy mức độ nguy cơ cao nhất từ 3 loại nguy cơ
  static int getHighestRiskLevel(HourlyForecastPoint? forecastPoint) {
    if (forecastPoint == null) return 0;

    try {
      // Chuyển đổi các giá trị nguy cơ sang số
      double luQuet = double.parse(forecastPoint.nguyCoLuQuet);
      double truotNong = double.parse(forecastPoint.nguyCoTruotNong);
      double truotLon = double.parse(forecastPoint.nguyCoTruotLon);

      // Lấy mức độ nguy cơ cho từng loại
      int luQuetLevel = _getRiskLevel(luQuet);
      int truotNongLevel = _getRiskLevel(truotNong);
      int truotLonLevel = _getRiskLevel(truotLon);

      // Trả về mức độ cao nhất
      return [luQuetLevel, truotNongLevel, truotLonLevel].reduce(max);
    } catch (e) {
      print('Error calculating risk level: $e');
      return 0;
    }
  }

  /// Tạo danh sách markers cho bản đồ
  static List<Marker> buildMarkers({
    required List<LandslidePoint> points,
    required bool showLandslidePoints,
    required Function(int) onTap,
    HourlyForecastResponse? forecastResponse,
  }) {
    if (!showLandslidePoints) return [];

    return points.map((point) {
      // Kiểm tra và lấy dữ liệu cảnh báo
      HourlyForecastPoint? matchingForecast;
      if (forecastResponse != null && 
          forecastResponse.data.isNotEmpty && 
          forecastResponse.totalPoints > 0) {
        try {
          final latestHourKey = forecastResponse.data.keys.first;
          final latestHourData = forecastResponse.data[latestHourKey] ?? [];
          matchingForecast = latestHourData.firstWhere(
            (forecast) => forecast.landslideId == point.id,
            // orElse: () => null,
          );
        } catch (e) {
          print('Error finding matching forecast for point ${point.id}: $e');
          matchingForecast = null;
        }
      }

      // Xác định mức độ nguy cơ và hình ảnh tương ứng
      final riskLevel = getHighestRiskLevel(matchingForecast);
      final markerIcon = 'lib/assets/map/landslide_$riskLevel.png';

      return Marker(
        point: point.location,
        width: 32,
        height: 32,
        child: GestureDetector(
          onTap: () => onTap(point.id),
          child: Image.asset(
            markerIcon,
            fit: BoxFit.contain,
          ),
        ),
      );
    }).toList();
  }
}