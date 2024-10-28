// lib/src/data/map/landslide_point.dart

import 'package:latlong2/latlong.dart';

class LandslidePoint {
  final int id;
  final double lon;
  final double lat;
  final int? communeId;
  final String? viTri;
  final String? moTa;
  final String districtName;
  final String communeName;
  final List<String> images;

  const LandslidePoint({
    required this.id,
    required this.lon,
    required this.lat,
    this.communeId,
    this.viTri,
    this.moTa,
    required this.districtName,
    required this.communeName,
    required this.images,
  });

  factory LandslidePoint.fromJson(Map<String, dynamic> json) {
    List<String> processImages(List<dynamic>? imageList) {
      print('Raw images data: $imageList');
      if (imageList == null || imageList.isEmpty) {
        print('No images for point ID: ${json['id']}');
        return [];
      }

      const baseUrl = 'http://truotlobinhdinh.girc.edu.vn/storage';
      var urls = imageList.map((path) {
        var fullUrl = '$baseUrl/$path';
        print('Created image URL: $fullUrl');
        return fullUrl;
      }).toList();

      print('Processed image URLs for point ${json['id']}: $urls');
      return urls;
    }

    print('Processing JSON data: ${json.toString()}');
    var point = LandslidePoint(
      id: json['id'],
      lon: double.parse(json['lon'].toString()),
      lat: double.parse(json['lat'].toString()),
      communeId: json['commune_id'],
      viTri: json['vi_tri'],
      moTa: json['mo_ta'],
      districtName: json['district_name'] ?? '',
      communeName: json['commune_name'] ?? '',
      images: processImages(json['images'] as List?),
    );

    print('Created LandslidePoint with images: ${point.images}');
    return point;
  }

  LatLng get location => LatLng(lat, lon);

  @override
  String toString() {
    return '''
LandslidePoint:
  ID: $id
  Location: ($lat, $lon)
  District: $districtName
  Commune: $communeName
  Images: $images
''';
  }
}