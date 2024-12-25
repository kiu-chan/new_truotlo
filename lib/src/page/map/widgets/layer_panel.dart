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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: showLayerPanel ? 0 : -280,
      top: 0,
      bottom: 0,
      width: 280,
      child: Card(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 8,
          right: 8,
        ),
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.layers,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Lớp bản đồ',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.blue.shade700,
                    ),
                    onPressed: onClose,
                    tooltip: 'Đóng',
                  ),
                ],
              ),
            ),
            
            // Layer switches
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLayerSection(
                    'Ranh giới hành chính',
                    [
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLayerSection(
                    'Điểm trượt lở',
                    [
                      _buildLayerSwitch(
                        'Hiển thị điểm',
                        Icons.warning_rounded,
                        showLandslidePoints,
                        onLandslidePointsChanged,
                        context,
                      ),
                    ],
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

  Widget _buildLayerSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade900,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade100,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(
          icon,
          size: 22,
          color: value ? Colors.blue.shade600 : Colors.grey.shade600,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: value ? Colors.blue.shade700 : Colors.grey.shade700,
            fontWeight: value ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue.shade600,
          activeTrackColor: Colors.blue.shade100,
        ),
      ),
    );
  }
}