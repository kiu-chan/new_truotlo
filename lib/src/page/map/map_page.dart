// lib/src/page/map/map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:new_truotlo/src/data/map/district_data.dart';
import 'package:new_truotlo/src/data/map/landslide_point.dart';
import 'package:new_truotlo/src/data/map/commune.dart';
import 'package:new_truotlo/src/database/database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
  bool _isLoading = true;

  bool _showDistricts = true;
  bool _showCommunes = false;
  bool _showLandslidePoints = true;
  bool _showLayerPanel = false;

  static const LatLng _binhDinhCenter = LatLng(14.1766, 109.1746);
  static const double _initialZoom = 9.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _database.connect();
      
      final districts = await _database.fetchDistrictsData();
      final communes = await _database.fetchCommunesData();
      final landslidePoints = await _database.fetchLandslidePoints();
      
      print('Loaded ${districts.length} districts');
      print('Loaded ${communes.length} communes');
      print('Loaded ${landslidePoints.length} landslide points');
      
      if (landslidePoints.isNotEmpty) {
        print('Sample point: ${landslidePoints.first}');
        if (landslidePoints.first.images.isNotEmpty) {
          print('Sample image URL: ${landslidePoints.first.images.first}');
        }
      }

      setState(() {
        _districts = districts;
        _communes = communes;
        _landslidePoints = landslidePoints;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading map data: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
    
    return polygons;
  }

  List<Marker> _buildMarkers() {
    if (!_showLandslidePoints) return [];
    
    return _landslidePoints.map((point) {
      return Marker(
        point: point.location,
        width: 30,
        height: 30,
        child: GestureDetector(
          onTap: () => _showLandslideInfo(point),
          child: const Icon(
            Icons.warning,
            color: Colors.red,
            size: 30,
          ),
        ),
      );
    }).toList();
  }

void _showLandslideInfo(LandslidePoint point) {
  print('Showing info for point ${point.id}');
  print('Images: ${point.images}');

  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thông tin điểm trượt lở',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('ID', '${point.id}'),
                    if (point.districtName.isNotEmpty)
                      _buildInfoRow('Quận/Huyện', point.districtName),
                    if (point.communeName.isNotEmpty)
                      _buildInfoRow('Xã/Phường', point.communeName),
                    _buildInfoRow('Tọa độ', '${point.lat}, ${point.lon}'),
                    if (point.viTri?.isNotEmpty == true)
                      _buildInfoRow('Vị trí', point.viTri!),
                    if (point.moTa?.isNotEmpty == true)
                      _buildInfoRow('Mô tả', point.moTa!),
                    if (point.images.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hình ảnh:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text('${point.images.length} hình'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: point.images.length,
                          itemBuilder: (context, index) {
                            final imageUrl = point.images[index];
                            print('Loading image: $imageUrl');
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => _showFullScreenImage(
                                  context,
                                  point.images,
                                  index,
                                ),
                                child: Container(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) {
                                        print('Error loading image: $error for URL: $url');
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.error_outline,
                                                  color: Colors.red,
                                                  size: 32,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Không thể tải hình',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    ),
  );
}

  void _showFullScreenImage(BuildContext context, List<String> images, int initialIndex) {
    print('Opening image gallery with ${images.length} images');
    print('Initial image: ${images[initialIndex]}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(images[index]),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
                itemCount: images.length,
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                pageController: PageController(initialPage: initialIndex),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hình ${initialIndex + 1}/${images.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _binhDinhCenter,
              initialZoom: _initialZoom,
              minZoom: 4.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              PolygonLayer(
                polygons: _buildPolygons(),
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
          if (_showLayerPanel)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 200,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hiển thị:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Quận/Huyện'),
                      value: _showDistricts,
onChanged: (bool value) {
                        setState(() {
                          _showDistricts = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Xã/Phường'),
                      value: _showCommunes,
                      onChanged: (bool value) {
                        setState(() {
                          _showCommunes = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Điểm trượt lở'),
                      value: _showLandslidePoints,
                      onChanged: (bool value) {
                        setState(() {
                          _showLandslidePoints = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoomIn",
                  mini: true,
                  onPressed: () {
                    final newZoom = _mapController.camera.zoom + 1.0;
                    if (newZoom <= 18.0) {
                      _mapController.move(
                        _mapController.camera.center,
                        newZoom,
                      );
                    }
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  mini: true,
                  onPressed: () {
                    final newZoom = _mapController.camera.zoom - 1.0;
                    if (newZoom >= 4.0) {
                      _mapController.move(
                        _mapController.camera.center,
                        newZoom,
                      );
                    }
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
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