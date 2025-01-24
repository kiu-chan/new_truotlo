// lib/src/page/map/widgets/map_type_sheet.dart

import 'package:flutter/material.dart';
import 'package:new_truotlo/src/page/map/utils/map_types.dart';

class MapTypeSheet extends StatelessWidget {
  final MapType currentType;
  final Function(MapType) onMapTypeChanged;

  const MapTypeSheet({
    super.key,
    required this.currentType,
    required this.onMapTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  Icon(
                    Icons.layers,
                    color: Colors.blue[700],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Chọn kiểu bản đồ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Map type options
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMapTypeOption(
                    context,
                    MapType.street,
                    'Đường phố',
                    Icons.map_outlined,
                  ),
                  _buildMapTypeOption(
                    context,
                    MapType.satellite,
                    'Vệ tinh',
                    Icons.satellite_outlined,
                  ),
                  _buildMapTypeOption(
                    context,
                    MapType.terrain,
                    'Địa hình',
                    Icons.terrain,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTypeOption(
    BuildContext context,
    MapType type,
    String label,
    IconData icon,
  ) {
    final bool isSelected = currentType == type;

    return InkWell(
      onTap: () {
        onMapTypeChanged(type);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.blue.shade400 : Colors.grey.shade200,
                  width: 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.blue.shade100.withAlpha((0.5 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}