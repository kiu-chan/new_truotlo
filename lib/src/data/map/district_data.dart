
import 'package:latlong2/latlong.dart' as latlong;

class District {
  final int id;
  final String name;
  final List<List<latlong.LatLng>> polygons;

  District(this.id, this.name, this.polygons);

  factory District.fromJson(Map<String, dynamic> json) {
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
        }
        return polygons;
      }

      return District(
        json['id'],
        json['name'],
        processPolygons(json['geometry']),
      );
    } catch (e) {
      return District(0, '', []);
    }
  }
}