// lib/src/utils/map_bounds_handler.dart

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapBoundsHandler {
  /// Tính toán bounds từ danh sách các polygon
  static LatLngBounds calculateBounds(List<List<LatLng>> borderPolygons) {
    if (borderPolygons.isEmpty) {
      // Default bounds cho Bình Định nếu không có polygon
      return LatLngBounds(
        const LatLng(13.5, 108.5),  // South West
        const LatLng(14.5, 109.5),  // North East
      );
    }

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLon = double.infinity;
    double maxLon = -double.infinity;

    for (var polygon in borderPolygons) {
      for (var point in polygon) {
        minLat = point.latitude < minLat ? point.latitude : minLat;
        maxLat = point.latitude > maxLat ? point.latitude : maxLat;
        minLon = point.longitude < minLon ? point.longitude : minLon;
        maxLon = point.longitude > maxLon ? point.longitude : maxLon;
      }
    }

    // Thêm padding để tránh giới hạn quá sát
    const padding = 0.1; // degrees
    return LatLngBounds(
      LatLng(minLat - padding, minLon - padding),  // South West
      LatLng(maxLat + padding, maxLon + padding),  // North East
    );
  }

  /// Kiểm tra và điều chỉnh center point để nằm trong bounds
  static LatLng enforceCenter(LatLng center, LatLngBounds bounds) {
    final double lat = center.latitude.clamp(
      bounds.southWest.latitude,
      bounds.northEast.latitude,
    );
    final double lon = center.longitude.clamp(
      bounds.southWest.longitude,
      bounds.northEast.longitude,
    );
    return LatLng(lat, lon);
  }
}