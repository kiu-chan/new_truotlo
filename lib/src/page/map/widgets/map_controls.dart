// lib/src/page/map/widgets/map_controls.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapControls extends StatelessWidget {
  final MapController mapController;
  final VoidCallback onDefaultLocationPressed;
  final double minZoom;
  final double maxZoom;

  const MapControls({
    super.key,
    required this.mapController,
    required this.onDefaultLocationPressed,
    this.minZoom = 4.0,
    this.maxZoom = 18.0,
  });

  @override
  Widget build(BuildContext context) {
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
              if (newZoom <= maxZoom) {
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
              if (newZoom >= minZoom) {
                mapController.move(
                  mapController.camera.center,
                  newZoom,
                );
              }
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "defaultLocation",
            mini: true,
            onPressed: onDefaultLocationPressed,
            backgroundColor: Theme.of(context).primaryColor,
            tooltip: 'Về vị trí mặc định',
            child: const Icon(Icons.home),
          ),
        ],
      ),
    );
  }
}