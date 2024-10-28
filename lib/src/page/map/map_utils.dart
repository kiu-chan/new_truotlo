// lib/src/page/map/map_utils.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:new_truotlo/src/data/map/district_data.dart';
import 'package:new_truotlo/src/data/map/commune.dart';
import 'package:new_truotlo/src/data/map/landslide_point.dart';

class MapUtils {
  static const LatLng binhDinhCenter = LatLng(14.1766, 109.1746);
  static const double defaultZoom = 9.0;
  static const double minZoom = 4.0;
  static const double maxZoom = 18.0;

  static List<Polygon> buildPolygons({
    required List<District> districts,
    required List<Commune> communes,
    required bool showDistricts,
    required bool showCommunes,
  }) {
    List<Polygon> polygons = [];
    
    // Add district polygons
    if (showDistricts) {
      for (var district in districts) {
        for (var polygon in district.polygons) {
          polygons.add(
            Polygon(
              points: polygon,
              color: Colors.blue.withOpacity(0.2),
              borderColor: Colors.blue,
              borderStrokeWidth: 2.0,
              isFilled: true,
              label: district.name,
            ),
          );
        }
      }
    }
    
    // Add commune polygons
    if (showCommunes) {
      for (var commune in communes) {
        for (var polygon in commune.polygons) {
          polygons.add(
            Polygon(
              points: polygon,
              color: Colors.green.withOpacity(0.2),
              borderColor: Colors.green,
              borderStrokeWidth: 1.0,
              isFilled: true,
              label: commune.name,
            ),
          );
        }
      }
    }
    
    return polygons;
  }

  static List<Marker> buildMarkers({
    required List<LandslidePoint> points,
    required bool showLandslidePoints,
    required Function(LandslidePoint) onTap,
  }) {
    if (!showLandslidePoints) return [];
    
    return points.map((point) {
      return Marker(
        point: LatLng(point.lat, point.lon),
        width: 30,
        height: 30,
        child: GestureDetector(
          onTap: () => onTap(point),
          child: const Icon(
            Icons.warning,
            color: Colors.red,
            size: 30,
          ),
        ),
      );
    }).toList();
  }
}