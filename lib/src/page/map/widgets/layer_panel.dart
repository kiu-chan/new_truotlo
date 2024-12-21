import 'package:flutter/material.dart';

class LayerPanel extends StatelessWidget {
  final bool showLayerPanel;
  final bool showDistricts;
  final bool showCommunes;
  final bool showLandslidePoints;
  final bool showBorder;  // New parameter
  final Function(bool) onDistrictsChanged;
  final Function(bool) onCommunesChanged;
  final Function(bool) onLandslidePointsChanged;
  final Function(bool) onBorderChanged;  // New parameter

  const LayerPanel({
    Key? key,
    required this.showLayerPanel,
    required this.showDistricts,
    required this.showCommunes,
    required this.showLandslidePoints,
    required this.showBorder,  // New parameter
    required this.onDistrictsChanged,
    required this.onCommunesChanged,
    required this.onLandslidePointsChanged,
    required this.onBorderChanged,  // New parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      right: showLayerPanel ? 0 : -200,
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
              title: const Text('Ranh giới tỉnh'),
              value: showBorder,
              onChanged: onBorderChanged,
            ),
            SwitchListTile(
              title: const Text('Quận/Huyện'),
              value: showDistricts,
              onChanged: onDistrictsChanged,
            ),
            SwitchListTile(
              title: const Text('Xã/Phường'),
              value: showCommunes,
              onChanged: onCommunesChanged,
            ),
            SwitchListTile(
              title: const Text('Điểm trượt lở'),
              value: showLandslidePoints,
              onChanged: onLandslidePointsChanged,
            ),
          ],
        ),
      ),
    );
  }
}