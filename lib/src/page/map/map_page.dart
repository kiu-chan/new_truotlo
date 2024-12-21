import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:new_truotlo/src/page/map/elements/map_icons.dart';
import 'package:new_truotlo/src/page/map/elements/map_legend.dart';
import 'menu.dart';
import 'map_state.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> with MapState {
  final LatLngBounds binhDinhBounds = LatLngBounds(
    southwest: const LatLng(13.0830, 108.0965),
    northeast: const LatLng(14.9088, 109.8837),
  );

  late CameraPosition _lastValidCameraPosition;

  @override
  void initState() {
    super.initState();
    connectToDatabase();
    initializeLocationService();
    _lastValidCameraPosition = CameraPosition(
      target: defaultTarget,
      zoom: defaultZoom,
    );
  }

  void showInfoPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MapLegend(buildRiskIcon: MapIcons.buildRiskIcon);
      },
    );
  }

  void _checkAndUpdateCamera(CameraPosition position) {
    if (!_isPositionInBounds(position.target)) {
      mapController.moveCamera(
        CameraUpdate.newCameraPosition(_lastValidCameraPosition),
      );
    } else {
      _lastValidCameraPosition = position;
    }
  }

  bool _isPositionInBounds(LatLng position) {
    return position.latitude >= binhDinhBounds.southwest.latitude &&
        position.latitude <= binhDinhBounds.northeast.latitude &&
        position.longitude >= binhDinhBounds.southwest.longitude &&
        position.longitude <= binhDinhBounds.northeast.longitude;
  }

  @override
  void moveToDefaultLocation() {
    final defaultPosition = CameraPosition(
      target: defaultTarget,
      zoom: defaultZoom,
    );
    if (_isPositionInBounds(defaultTarget)) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(defaultPosition));
      _lastValidCameraPosition = defaultPosition;
    }
  }

  @override
  void moveToCurrentLocation() {
    if (currentLocation != null) {
      if (_isPositionInBounds(currentLocation!)) {
        final newPosition = CameraPosition(
          target: currentLocation!,
          zoom: mapController.cameraPosition?.zoom ?? defaultZoom,
        );
        mapController.animateCamera(CameraUpdate.newCameraPosition(newPosition));
        _lastValidCameraPosition = newPosition;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vị trí hiện tại nằm ngoài khu vực Bình Định')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: showInfoPopup,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: MapMenu(
        styleCategories: styleCategories,
        currentStyle: currentStyle,
        isDistrictsVisible: isDistrictsVisible,
        isBorderVisible: isBorderVisible,
        isCommunesVisible: isCommunesVisible,
        isLandslidePointsVisible: isLandslidePointsVisible,
        districts: districts,
        districtVisibility: districtVisibility,
        districtLandslideVisibility: districtLandslideVisibility,
        onStyleChanged: changeMapStyle,
        onDistrictsVisibilityChanged: toggleDistrictsVisibility,
        onBorderVisibilityChanged: toggleBorderVisibility,
        onCommunesVisibilityChanged: toggleCommunesVisibility,
        onLandslidePointsVisibilityChanged: toggleLandslidePointsVisibility,
        onDistrictVisibilityChanged: toggleDistrictVisibility,
        onDistrictLandslideVisibilityChanged: toggleDistrictLandslideVisibility,
        showOnlyLandslideRisk: showOnlyLandslideRisk,
        showOnlyFlashFloodRisk: showOnlyFlashFloodRisk,
        showOnlyLargeSlideRisk: showOnlyLargeSlideRisk,
        onShowOnlyLandslideRiskChanged: toggleShowOnlyLandslideRisk,
        onShowOnlyFlashFloodRiskChanged: toggleShowOnlyFlashFloodRisk,
        onShowOnlyLargeSlideRiskChanged: toggleShowOnlyLargeSlideRisk,
      ),
      body: Stack(
        children: [
          MapboxMap(
            accessToken: mapToken,
            initialCameraPosition: CameraPosition(
              target: defaultTarget,
              zoom: defaultZoom,
            ),
            styleString: currentStyle,
            onStyleLoadedCallback: onStyleLoaded,
            onMapCreated: onMapCreated,
            minMaxZoomPreference: const MinMaxZoomPreference(5.0, 18.0),
            compassEnabled: true,
            compassViewPosition: CompassViewPosition.TopRight,
            onCameraTrackingDismissed: () {},
            trackCameraPosition: true,
            onMapIdle: () {
              if (mapController.cameraPosition != null) {
                _checkAndUpdateCamera(mapController.cameraPosition!);
              }
            },
          ),
          buildRouteInfo(),
          if (currentLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                ),
                child: Text(
                  'Vị trí cá nhân hiện tại: ${currentLocation!.latitude.toStringAsFixed(6)}, ${currentLocation!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: moveToCurrentLocation,
            heroTag: 'moveToCurrentLocation',
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: moveToDefaultLocation,
            heroTag: 'moveToDefaultLocation',
            backgroundColor: Colors.white,
            child: const Icon(Icons.home, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    locationService.stopLocationUpdates();
    mapController.onSymbolTapped.remove(onSymbolTapped);
    super.dispose();
  }
}