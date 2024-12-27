// lib/src/data/map/commune.dart

import 'package:latlong2/latlong.dart' as latlong;

class Commune {
  final int id;
  final String name;
  final String districtName;
  final String provinceName;
  final List<List<latlong.LatLng>> polygons;

  Commune(this.id, this.name, this.districtName, this.provinceName, this.polygons);

  factory Commune.fromJson(Map<String, dynamic> json) {
    try {
      List<List<latlong.LatLng>> processPolygons(Map<String, dynamic> geometry) {
        List<List<latlong.LatLng>> polygons = [];
        if (geometry['type'] == 'MultiPolygon') {
          List<dynamic> coordinates = geometry['coordinates'];
          for (var polygon in coordinates) {
            List<latlong.LatLng> points = [];
            for (var coordinate in polygon[0]) {
              double lng = double.parse(coordinate[0].toString());
              double lat = double.parse(coordinate[1].toString());
              points.add(latlong.LatLng(lat, lng));
            }
            polygons.add(points);
          }
        } else if (geometry['type'] == 'Polygon') {
          List<latlong.LatLng> points = [];
          List<dynamic> coordinates = geometry['coordinates'][0];
          for (var coordinate in coordinates) {
            double lng = double.parse(coordinate[0].toString());
            double lat = double.parse(coordinate[1].toString());
            points.add(latlong.LatLng(lat, lng));
          }
          polygons.add(points);
        }
        return polygons;
      }

      return Commune(
        json['id'],
        json['name'],
        json['district_name'],
        json['province_name'],
        processPolygons(json['geometry']),
      );
    } catch (e) {
      return Commune(0, '', '', '', []);
    }
  }
}