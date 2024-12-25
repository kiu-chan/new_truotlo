// lib/src/page/map/widgets/map_controls.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapControls extends StatelessWidget {
  final MapController mapController;
  final VoidCallback onDefaultLocationPressed;
  final VoidCallback onLocationPressed;
  final bool isTrackingLocation;
  final double minZoom;
  final double maxZoom;

  const MapControls({
    super.key,
    required this.mapController,
    required this.onDefaultLocationPressed,
    required this.onLocationPressed,
    required this.isTrackingLocation,
    this.minZoom = 4.0,
    this.maxZoom = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlButton(
                context,
                icon: Icons.add,
                tooltip: 'Phóng to',
                heroTag: 'zoomIn',
                onPressed: () {
                  final newZoom = mapController.camera.zoom + 1.0;
                  if (newZoom <= maxZoom) {
                    mapController.move(
                      mapController.camera.center,
                      newZoom,
                    );
                  }
                },
              ),
              const Divider(height: 1),
              _buildControlButton(
                context,
                icon: Icons.remove,
                tooltip: 'Thu nhỏ',
                heroTag: 'zoomOut',
                onPressed: () {
                  final newZoom = mapController.camera.zoom - 1.0;
                  if (newZoom >= minZoom) {
                    mapController.move(
                      mapController.camera.center,
                      newZoom,
                    );
                  }
                },
              ),
              const Divider(height: 1),
              _buildControlButton(
                context,
                icon: Icons.home,
                tooltip: 'Về vị trí mặc định',
                heroTag: 'defaultLocation',
                onPressed: onDefaultLocationPressed,
              ),
              const Divider(height: 1),
              _buildControlButton(
                context,
                icon: isTrackingLocation ? Icons.gps_fixed : Icons.gps_not_fixed,
                tooltip: 'Vị trí của tôi',
                heroTag: 'location',
                onPressed: isTrackingLocation ? null : onLocationPressed,
                color: isTrackingLocation ? Colors.grey : Colors.blue.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required String heroTag,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 20,
          color: color ?? Colors.blue.shade700,
        ),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}