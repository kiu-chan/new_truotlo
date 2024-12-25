// lib/src/data/manage/landslide_point.dart
class ManageLandslidePoint {
  final String id;
  final String name;
  final String code;
  final double latitude;
  final double longitude;
  final String description;
  final List<String> imagePaths;

  ManageLandslidePoint({
    required this.id,
    required this.name,
    required this.code,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.imagePaths,
  });

  factory ManageLandslidePoint.fromJson(Map<String, dynamic> json) {
    return ManageLandslidePoint(
      id: json['id'].toString(),
      name: json['name'] as String,
      code: json['code'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      imagePaths: (json['image_paths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }
}