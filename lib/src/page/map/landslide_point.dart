// lib/src/data/map/landslide_point.dart

import 'package:latlong2/latlong.dart';

class LandslidePoint {
  final int id;
  final LatLng location;
  final String district;
  final String? description;
  final String? date;
  final String? status;
  final List<String>? images;

  LandslidePoint({
    required this.id,
    required this.location,
    required this.district,
    this.description,
    this.date,
    this.status,
    this.images,
  });

  factory LandslidePoint.fromJson(Map<String, dynamic> json) {
    return LandslidePoint(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      location: LatLng(
        _parseDouble(json['lat']),
        _parseDouble(json['lon'])
      ),
      district: json['district'] as String,
      description: json['description'] as String?,
      date: json['date'] as String?,
      status: json['status'] as String?,
      images: json['images'] != null 
        ? List<String>.from(json['images'])
        : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    throw FormatException('Invalid numeric value: $value');
  }
}