// lib/src/page/map/widgets/district_labels.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:new_truotlo/src/data/map/district_data.dart';

class DistrictLabels extends StatelessWidget {
  final List<District> districts;
  final bool showLabels;

  const DistrictLabels({
    super.key,
    required this.districts,
    required this.showLabels,
  });

  List<Marker> _buildDistrictLabels() {
    if (!showLabels) return [];

    return districts.map((district) {
      if (district.polygons.isEmpty) return null;

      final points = district.polygons.first;
      double centerLat = 0;
      double centerLon = 0;
      
      for (var point in points) {
        centerLat += point.latitude;
        centerLon += point.longitude;
      }
      
      centerLat /= points.length;
      centerLon /= points.length;

      return Marker(
        point: LatLng(centerLat, centerLon),
        width: 150,
        height: 30,
        child: Stack(
          children: [
            // Viền trắng
            Text(
              district.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = Colors.white,
              ),
            ),
            // Chữ đen
            Text(
              district.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }).whereType<Marker>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(markers: _buildDistrictLabels());
  }
}