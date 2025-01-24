// lib/src/page/map/map_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:new_truotlo/src/data/map/landslide_point.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class MapWidgets {
  static Widget buildLayerPanel({
    required bool showLayerPanel,
    required bool showDistricts,
    required bool showCommunes,
    required bool showLandslidePoints,
    required Function(bool) onDistrictsChanged,
    required Function(bool) onCommunesChanged,
    required Function(bool) onLandslidePointsChanged,
    required BuildContext context,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      right: showLayerPanel ? 0 : -250,
      top: 0,
      bottom: 0,
      width: 250,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).round()),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: const Row(
                children: [
                  Icon(Icons.layers, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Lớp bản đồ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _buildLayerSwitch(
                    'Quận/Huyện',
                    Icons.location_city,
                    showDistricts,
                    onDistrictsChanged,
                    context,
                  ),
                  _buildLayerSwitch(
                    'Xã/Phường',
                    Icons.location_on,
                    showCommunes,
                    onCommunesChanged,
                    context,
                  ),
                  _buildLayerSwitch(
                    'Điểm trượt lở',
                    Icons.warning_amber,
                    showLandslidePoints,
                    onLandslidePointsChanged,
                    context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLayerSwitch(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  static Widget buildMapControls(MapController mapController) {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "zoomIn",
            mini: true,
            onPressed: () {
              final newZoom = mapController.camera.zoom + 1.0;
              if (newZoom <= 18.0) {
                mapController.move(
                  mapController.camera.center,
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
              final newZoom = mapController.camera.zoom - 1.0;
              if (newZoom >= 4.0) {
                mapController.move(
                  mapController.camera.center,
                  newZoom,
                );
              }
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  static void showLandslideInfo(BuildContext context, LandslidePoint point) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thông tin điểm trượt lở',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(point),
                      const SizedBox(height: 16),
                      if (point.images.isNotEmpty)
                        _buildImageCarousel(context, point.images),
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

  static Widget _buildInfoSection(LandslidePoint point) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('ID', '${point.id}'),
        _buildInfoRow('Quận/Huyện', point.districtName),
        _buildInfoRow('Xã/Phường', point.communeName),
        if (point.viTri?.isNotEmpty == true)
          _buildInfoRow('Vị trí', point.viTri!),
        _buildInfoRow('Tọa độ', '${point.lat}, ${point.lon}'),
        if (point.moTa?.isNotEmpty == true)
          _buildInfoRow('Mô tả', point.moTa!),
      ],
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
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

  static Widget _buildImageCarousel(BuildContext context, List<String> images) {
    print('Building carousel with images: $images');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Hình ảnh',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            viewportFraction: 0.8,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
          ),
          items: images.map((imageUrl) {
            print('Loading image: $imageUrl');
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => _showFullScreenImage(context, images, images.indexOf(imageUrl)),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
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
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(height: 8),
                                Text(
                                  'Không thể tải hình\n$url',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red[300],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  static void _showFullScreenImage(BuildContext context, List<String> images, int initialIndex) {
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
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            'Không thể tải hình',
                            style: TextStyle(
                              color: Colors.red[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: images.length,
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                pageController: PageController(initialPage: initialIndex),
              ),
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black26,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hình ${initialIndex + 1}/${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
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
}