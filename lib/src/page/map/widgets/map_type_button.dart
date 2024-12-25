// lib/src/page/map/widgets/map_type_button.dart

import 'package:flutter/material.dart';
import 'package:new_truotlo/src/page/map/utils/map_types.dart';
import 'package:new_truotlo/src/page/map/widgets/map_type_sheet.dart';

class MapTypeButton extends StatelessWidget {
  final MapType currentType;
  final Function(MapType) onMapTypeChanged;

  const MapTypeButton({
    super.key,
    required this.currentType,
    required this.onMapTypeChanged,
  });

  void _showMapTypeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => MapTypeSheet(
        currentType: currentType,
        onMapTypeChanged: onMapTypeChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.shade100,
            width: 1,
          ),
        ),
        child: IconButton(
          icon: Icon(
            Icons.layers,
            color: Colors.blue.shade700,
            size: 24,
          ),
          onPressed: () => _showMapTypeSheet(context),
          tooltip: 'Chọn loại bản đồ',
          splashRadius: 24,
        ),
      ),
    );
  }
}