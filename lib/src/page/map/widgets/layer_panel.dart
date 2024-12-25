import 'package:flutter/material.dart';
import 'package:new_truotlo/src/page/map/widgets/map_legend.dart';

class LayerPanel extends StatelessWidget {
  final bool showLayerPanel;
  final bool showDistricts;
  final bool showCommunes;
  final bool showLandslidePoints;
  final bool showBorder;
  final Function(bool) onDistrictsChanged;
  final Function(bool) onCommunesChanged;
  final Function(bool) onLandslidePointsChanged;
  final Function(bool) onBorderChanged;
  final VoidCallback onClose;

  const LayerPanel({
    super.key,
    required this.showLayerPanel,
    required this.showDistricts,
    required this.showCommunes,
    required this.showLandslidePoints,
    required this.showBorder,
    required this.onDistrictsChanged,
    required this.onCommunesChanged,
    required this.onLandslidePointsChanged,
    required this.onBorderChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      right: showLayerPanel ? 0 : -250,
      top: 0,
      bottom: 0,
      width: 250,
      child: Card(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: 8,
          right: 8,
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
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
                  const Row(
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
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Đóng',
                  ),
                ],
              ),
            ),
            
            // Layer switches
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLayerSwitch(
                    'Ranh giới tỉnh',
                    Icons.blur_on,
                    showBorder,
                    onBorderChanged,
                    context,
                  ),
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
            
            const Divider(height: 1),
            
            // Legend
            const Expanded(
              child: SingleChildScrollView(
                child: MapLegend(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerSwitch(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        leading: Icon(icon, size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}