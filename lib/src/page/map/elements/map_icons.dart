import 'package:flutter/material.dart';

class MapIcons {
  static Widget buildRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'no_risk':
        return Image.asset('lib/assets/map/landslide_0.png', width: 16, height: 16);
      case 'very_low':
        return Image.asset('lib/assets/map/landslide_1.png', width: 16, height: 16);
      case 'low':
        return Image.asset('lib/assets/map/landslide_2.png', width: 16, height: 16);
      case 'medium':
        return Image.asset('lib/assets/map/landslide_3.png', width: 16, height: 16);
      case 'high':
        return Image.asset('lib/assets/map/landslide_4.png', width: 16, height: 16);
      case 'very_high':
        return Image.asset('lib/assets/map/landslide_5.png', width: 16, height: 16);
      default:
        return const SizedBox.shrink();
    }
  }

  static String getRiskIconPath(String riskLevel) {
    switch (riskLevel) {
      case 'no_risk':
        return 'lib/assets/map/landslide_0.png';
      case 'very_low':
        return 'lib/assets/map/landslide_1.png';
      case 'low':
        return 'lib/assets/map/landslide_2.png';
      case 'medium':
        return 'lib/assets/map/landslide_3.png';
      case 'high':
        return 'lib/assets/map/landslide_4.png';
      case 'very_high':
        return 'lib/assets/map/landslide_5.png';
      default:
        return 'lib/assets/map/landslide_0.png';
    }
  }
}