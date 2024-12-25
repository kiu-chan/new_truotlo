// lib/src/utils/map_type_helper.dart

import 'package:flutter/material.dart';

enum MapType {
  street,
  satellite,
  terrain
}

class MapTypeHelper {
  static String getUrlTemplate(MapType type) {
    switch (type) {
      case MapType.street:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapType.satellite:
        return 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';
      case MapType.terrain:
        return 'https://mt1.google.com/vt/lyrs=p&x={x}&y={y}&z={z}';
    }
  }

  static String getDisplayName(MapType type) {
    switch (type) {
      case MapType.street:
        return 'Đường phố';
      case MapType.satellite:
        return 'Vệ tinh';
      case MapType.terrain:
        return 'Địa hình';
    }
  }

  static Icon getIcon(MapType type) {
    switch (type) {
      case MapType.street:
        return const Icon(Icons.map_outlined);
      case MapType.satellite:
        return const Icon(Icons.satellite_outlined);
      case MapType.terrain:
        return const Icon(Icons.terrain);
    }
  }
}