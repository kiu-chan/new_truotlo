import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapControls extends StatelessWidget {
  final MapController mapController;

  const MapControls({
    Key? key,
    required this.mapController,
  }) : super(key: key);

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
}