// lib/src/page/map/map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_truotlo/src/page/map/utils/map_types.dart';
import 'package:new_truotlo/src/page/map/widgets/map_loading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:new_truotlo/src/page/map/utils/map_markers.dart';
import 'package:new_truotlo/src/page/map/utils/map_bounds_handler.dart';
import 'package:new_truotlo/src/page/map/widgets/landslide_info_dialog.dart';
import 'package:new_truotlo/src/page/map/widgets/layer_panel.dart';
import 'package:new_truotlo/src/page/map/widgets/map_controls.dart';
import 'package:new_truotlo/src/page/map/widgets/map_type_button.dart';
import 'package:new_truotlo/src/page/map/widgets/district_labels.dart';
import 'package:new_truotlo/src/data/map/district_data.dart';
import 'package:new_truotlo/src/data/map/commune.dart';
import 'package:new_truotlo/src/data/map/landslide_point.dart';
import 'package:new_truotlo/src/database/database.dart';
import 'package:new_truotlo/src/data/forecast/hourly_forecast_response.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Controllers
  final DefaultDatabase _database = DefaultDatabase();
  final MapController _mapController = MapController();
  
  // Data states
  List<District> _districts = [];
  List<Commune> _communes = [];
  List<LandslidePoint> _landslidePoints = [];
  List<List<LatLng>> _borderPolygons = [];
  HourlyForecastResponse? _forecastResponse;
  
  // UI states
  bool _isLoading = true;
  bool _showLayerPanel = false;
  bool _showDistricts = true;
  bool _showCommunes = false;
  bool _showLandslidePoints = true;
  bool _showBorder = false;
  MapType _currentMapType = MapType.street;
  
  // Location tracking states
  LatLng? _currentLocation;
  bool _isTrackingLocation = false;

  // Map bounds state
  late LatLngBounds _mapBounds;

  // Map constants
  static const LatLng _binhDinhCenter = LatLng(14.1766, 109.1746);
  static const double _initialZoom = 9.0;
  static const double _minZoom = 8.0;
  static const double _maxZoom = 18.0;

  @override
  void initState() {
    super.initState();
    _mapBounds = LatLngBounds(
      const LatLng(13.5, 108.5),  // South West
      const LatLng(14.5, 109.5),  // North East
    );
    _loadData();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      await _database.connect();
      
      final futures = await Future.wait([
        _database.fetchDistrictsData(),
        _database.fetchCommunesData(),
        _database.fetchLandslidePoints(),
        _database.fetchAndParseGeometry(),
        _database.fetchHourlyForecastPoints(),
      ]);
      
      setState(() {
        _districts = futures[0] as List<District>;
        _communes = futures[1] as List<Commune>;
        _landslidePoints = futures[2] as List<LandslidePoint>;
        _borderPolygons = futures[3] as List<List<LatLng>>;
        _forecastResponse = futures[4] as HourlyForecastResponse;
        
        _mapBounds = MapBoundsHandler.calculateBounds(_borderPolygons);
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading map data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi khi tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isTrackingLocation = true);

      final permission = await Permission.location.status;
      if (permission.isDenied) {
        if (mounted) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Yêu cầu quyền truy cập'),
              content: const Text('Ứng dụng cần quyền truy cập vị trí để hiển thị vị trí của bạn.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Đồng ý'),
                ),
              ],
            ),
          );
          
          if (result != true) return;
          await Permission.location.request();
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentLocation = MapBoundsHandler.enforceCenter(newLocation, _mapBounds);
      });

      _mapController.move(_currentLocation!, 15.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lấy vị trí: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isTrackingLocation = false);
    }
  }

  void _moveToDefaultLocation() {
    final center = MapBoundsHandler.enforceCenter(_binhDinhCenter, _mapBounds);
    _mapController.move(center, _initialZoom);
  }

  List<Polygon> _buildPolygons() {
    List<Polygon> polygons = [];
    
    if (_showDistricts) {
      for (var district in _districts) {
        for (var polygon in district.polygons) {
          polygons.add(
            Polygon(
              points: polygon,
              color: Colors.blue.withOpacity(0.2),
              borderColor: Colors.blue,
              borderStrokeWidth: 2.0,
              isFilled: true,
            ),
          );
        }
      }
    }
    
    if (_showCommunes) {
      for (var commune in _communes) {
        for (var polygon in commune.polygons) {
          polygons.add(
            Polygon(
              points: polygon,
              color: Colors.green.withOpacity(0.2),
              borderColor: Colors.green,
              borderStrokeWidth: 1.0,
              isFilled: true,
            ),
          );
        }
      }
    }
    
    if (_showBorder) {
      for (var polygon in _borderPolygons) {
        polygons.add(
          Polygon(
            points: polygon,
            color: Colors.transparent,
            borderColor: Colors.red,
            borderStrokeWidth: 2.0,
            isFilled: true,
          ),
        );
      }
    }
    
    return polygons;
  }

  List<Marker> _buildMarkers() {
    final List<Marker> markers = [];
    
    if (_showLandslidePoints) {
      markers.addAll(MapMarkersHandler.buildMarkers(
        points: _landslidePoints,
        showLandslidePoints: _showLandslidePoints,
        onTap: (id) => showLandslideInfoDialog(context, id),
        forecastResponse: _forecastResponse,
      ));
    }

    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 30,
          height: 30,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.7),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _binhDinhCenter,
              initialZoom: _initialZoom,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              bounds: _mapBounds,
              boundsOptions: const FitBoundsOptions(
                padding: EdgeInsets.all(20),
              ),
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture && position.center != null) {
                  final newCenter = MapBoundsHandler.enforceCenter(
                    position.center!,
                    _mapBounds,
                  );
                  if (newCenter != position.center) {
                    _mapController.move(newCenter, position.zoom ?? _initialZoom);
                  }
                }
              },
              interactionOptions: const InteractionOptions(
                enableScrollWheel: true,
                enableMultiFingerGestureRace: true,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: MapTypeHelper.getUrlTemplate(_currentMapType),
                userAgentPackageName: 'com.example.app',
                subdomains: const ['a', 'b', 'c'],
              ),
              PolygonLayer(
                polygons: _buildPolygons(),
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
              DistrictLabels(
                districts: _districts,
                showLabels: _showDistricts,
              ),
            ],
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  _showLayerPanel ? Icons.format_list_bulleted : Icons.format_list_bulleted_outlined,
                  color: Colors.blue.shade700,
                ),
                onPressed: () {
                  setState(() {
                    _showLayerPanel = !_showLayerPanel;
                  });
                },
                tooltip: 'Hiển thị/Ẩn bảng điều khiển lớp',
              ),
            ),
          ),
          
          LayerPanel(
            showLayerPanel: _showLayerPanel,
            showDistricts: _showDistricts,
            showCommunes: _showCommunes,
            showLandslidePoints: _showLandslidePoints,
            showBorder: _showBorder,
            onDistrictsChanged: (value) => setState(() => _showDistricts = value),
            onCommunesChanged: (value) => setState(() => _showCommunes = value),
            onLandslidePointsChanged: (value) => setState(() => _showLandslidePoints = value),
            onBorderChanged: (value) => setState(() => _showBorder = value),
            onClose: () => setState(() => _showLayerPanel = false),
          ),
          
          MapControls(
            mapController: _mapController,
            onDefaultLocationPressed: _moveToDefaultLocation,
            onLocationPressed: _getCurrentLocation,
            isTrackingLocation: _isTrackingLocation,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
          ),

          Positioned(
            bottom: 16,
            right: 16,
            child: MapTypeButton(
              currentType: _currentMapType,
              onMapTypeChanged: (type) => setState(() => _currentMapType = type),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}