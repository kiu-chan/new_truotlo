// lib/src/page/map/map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  final DefaultDatabase _database = DefaultDatabase();
  final MapController _mapController = MapController();
  
  List<District> _districts = [];
  List<Commune> _communes = [];
  List<LandslidePoint> _landslidePoints = [];
  List<List<LatLng>> _borderPolygons = [];
  HourlyForecastResponse? _forecastResponse;
  bool _isLoading = true;

  // Trạng thái hiển thị các lớp trên bản đồ
  bool _showDistricts = true;
  bool _showCommunes = false;
  bool _showLandslidePoints = true;
  bool _showLayerPanel = false;
  bool _showBorder = true;

  // Vị trí trung tâm của Bình Định
  static const LatLng _binhDinhCenter = LatLng(14.1766, 109.1746);
  static const double _initialZoom = 9.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

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
      setState(() {
        _isLoading = false;
      });
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

  // Xây dựng các marker cho điểm trượt lở
  List<Marker> _buildMarkers() {
    return MapMarkersHandler.buildMarkers(
      points: _landslidePoints,
      showLandslidePoints: _showLandslidePoints,
      onTap: (id) => showLandslideInfoDialog(context, id),
      forecastResponse: _forecastResponse,
    );
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
          // Widget bản đồ chính
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _binhDinhCenter,
              initialZoom: _initialZoom,
              minZoom: 4.0,
              maxZoom: 18.0,
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
              // Lớp các marker điểm trượt lở
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