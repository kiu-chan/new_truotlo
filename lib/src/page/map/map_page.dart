// lib/src/page/map/map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_truotlo/src/page/map/utils/location_permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:new_truotlo/src/page/map/utils/map_markers.dart';
import 'package:new_truotlo/src/page/map/widgets/landslide_info_dialog.dart';
import 'package:new_truotlo/src/page/map/widgets/layer_panel.dart';
import 'package:new_truotlo/src/page/map/widgets/map_controls.dart';
import 'package:new_truotlo/src/data/map/district_data.dart';
import 'package:new_truotlo/src/data/map/commune.dart';
import 'package:new_truotlo/src/data/map/landslide_point.dart';
import 'package:new_truotlo/src/database/database.dart';
import 'package:new_truotlo/src/data/forecast/hourly_forecast_response.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

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
  bool _showBorder = true;
  
  // Location tracking states
  LatLng? _currentLocation;
  bool _isTrackingLocation = false;

  // Constants
  static const LatLng _binhDinhCenter = LatLng(14.1766, 109.1746);
  static const double _initialZoom = 9.0;
  static const double _minZoom = 4.0;
  static const double _maxZoom = 18.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkLocationPermission();
  }

  // Kiểm tra và yêu cầu quyền truy cập vị trí
  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  // Load dữ liệu từ database
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

    // Xử lý quyền truy cập vị trí
    final hasPermission = await LocationPermissionHandler.handleLocationPermission(context);
    if (!hasPermission) {
      return;
    }

    // Lấy vị trí hiện tại
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    // Di chuyển bản đồ đến vị trí hiện tại
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

  // Xây dựng các polygon cho bản đồ
  List<Polygon> _buildPolygons() {
    List<Polygon> polygons = [];
    
    // Thêm polygon ranh giới tỉnh
    if (_showBorder) {
      for (var polygon in _borderPolygons) {
        polygons.add(
          Polygon(
            points: polygon,
            color: Colors.red.withOpacity(0.1),
            borderColor: Colors.red,
            borderStrokeWidth: 2.0,
            isFilled: true,
          ),
        );
      }
    }
    
    // Thêm polygon quận/huyện
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
    
    // Thêm polygon xã/phường
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
    
    return polygons;
  }

  // Xây dựng các marker cho bản đồ
  List<Marker> _buildMarkers() {
    final List<Marker> markers = [];
    
    // Thêm các markers điểm trượt lở
    markers.addAll(MapMarkersHandler.buildMarkers(
      points: _landslidePoints,
      showLandslidePoints: _showLandslidePoints,
      onTap: (id) => showLandslideInfoDialog(context, id),
      forecastResponse: _forecastResponse,
    ));

    // Thêm marker vị trí hiện tại nếu có
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
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải dữ liệu bản đồ...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ'),
        actions: [
          // Nút định vị
          IconButton(
            icon: Icon(_isTrackingLocation ? Icons.gps_fixed : Icons.gps_not_fixed),
            onPressed: _isTrackingLocation ? null : _getCurrentLocation,
            tooltip: 'Vị trí của tôi',
          ),
          // Nút hiển thị layer panel
          IconButton(
            icon: Icon(_showLayerPanel ? Icons.layers : Icons.layers_outlined),
            onPressed: () {
              setState(() {
                _showLayerPanel = !_showLayerPanel;
              });
            },
            tooltip: 'Hiển thị/Ẩn bảng điều khiển lớp',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _binhDinhCenter,
              initialZoom: _initialZoom,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              interactionOptions: const InteractionOptions(
                enableScrollWheel: true,
                enableMultiFingerGestureRace: true,
              ),
            ),
            children: [
              // Lớp nền OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                subdomains: const ['a', 'b', 'c'],
              ),
              // Lớp các polygon
              PolygonLayer(
                polygons: _buildPolygons(),
              ),
              // Lớp các marker
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
          // Bảng điều khiển lớp
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
          ),
          // Nút điều khiển zoom
          MapControls(mapController: _mapController),
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