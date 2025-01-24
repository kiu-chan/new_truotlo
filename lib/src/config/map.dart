import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:new_truotlo/src/page/map/utils/map_types.dart';

class MapConfig {
  static var mapBounds = LatLngBounds(
      const LatLng(13.5, 108.5), // South West
      const LatLng(14.5, 109.5), // North East
    );


  static const LatLng binhDinhCenter = LatLng(14.1766, 109.1746);
  static const double initialZoom = 9.0;
  static const double minZoom = 8.0;
  static const double maxZoom = 18.0;


  static const bool isLoading = true;
  static const bool showLayerPanel = false;
  static const bool showDistricts = true;
  static const bool showCommunes = false;
  static const bool showLandslidePoints = true;
  static const bool showBorder = false;
  static const MapType currentMapType = MapType.street;

  static const bool isTrackingLocation = false;
}