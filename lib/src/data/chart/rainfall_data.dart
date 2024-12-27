// lib/src/data/chart/rainfall_data.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RainfallData {
  final DateTime measurementTime;
  final double rainfallAmount;

  RainfallData({
    required this.measurementTime,
    required this.rainfallAmount,
  });

  factory RainfallData.fromJson(Map<String, dynamic> json) {
    return RainfallData(
      measurementTime: DateTime.parse(json['measurement_time']),
      // Convert to double since API might return int or double
      rainfallAmount: json['rainfall_amount'] is int 
          ? (json['rainfall_amount'] as int).toDouble()
          : double.parse(json['rainfall_amount'].toString()),
    );
  }
}

class RainfallDataService {
  static const String baseUrl = 'http://truotlobinhdinh.girc.edu.vn';

  static Future<List<RainfallData>> fetchRainfallData({
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool isAdmin = false,
  }) async {
    try {
      String url;
      
      if (startDateTime != null && endDateTime != null) {
        // Sử dụng API endpoint với bộ lọc
        final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
        final startStr = formatter.format(startDateTime);
        final endStr = formatter.format(endDateTime);
        
        url = '$baseUrl/api/rainfall-data?start_datetime=${Uri.encodeComponent(startStr)}&end_datetime=${Uri.encodeComponent(endStr)}';
      } else {
        // Sử dụng API endpoint mặc định
        url = '$baseUrl/rainfall-data';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        
        List<RainfallData> rainfallDataList = data
            .map((item) => RainfallData.fromJson(item))
            .toList();

        // Sort by measurement time
        rainfallDataList.sort((a, b) => 
          a.measurementTime.compareTo(b.measurementTime));

        // Nếu không phải admin và không có date range, chỉ lấy dữ liệu 48h gần nhất
        if (!isAdmin && startDateTime == null && endDateTime == null) {
          final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
          rainfallDataList = rainfallDataList
              .where((data) => data.measurementTime.isAfter(twoDaysAgo))
              .toList();
        }
        

        return rainfallDataList;
      } else {
        throw Exception('Failed to load rainfall data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}