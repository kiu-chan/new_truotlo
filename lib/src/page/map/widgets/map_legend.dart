// lib/src/page/map/widgets/map_legend.dart

import 'package:flutter/material.dart';

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Chú thích:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        _buildPolygonLegend(),
        const Divider(),
        _buildLandslideLegend(),
      ],
    );
  }

  Widget _buildPolygonLegend() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ranh giới hành chính:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildLineLegendItem(
            color: Colors.red,
            width: 2.0,
            label: 'Ranh giới tỉnh',
          ),
          const SizedBox(height: 4),
          _buildLineLegendItem(
            color: Colors.blue,
            width: 2.0,
            label: 'Quận/Huyện',
          ),
          const SizedBox(height: 4),
          _buildLineLegendItem(
            color: Colors.green,
            width: 1.0,
            label: 'Xã/Phường',
          ),
        ],
      ),
    );
  }

  Widget _buildLandslideLegend() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mức độ nguy cơ:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildRiskLegendItem(
            iconPath: 'lib/assets/map/landslide_0.png',
            label: 'Không có nguy cơ',
            value: '0',
          ),
          const SizedBox(height: 4),
          _buildRiskLegendItem(
            iconPath: 'lib/assets/map/landslide_1.png',
            label: 'Rất thấp',
            value: '0-2',
          ),
          const SizedBox(height: 4),
          _buildRiskLegendItem(
            iconPath: 'lib/assets/map/landslide_2.png',
            label: 'Thấp',
            value: '2-3',
          ),
          const SizedBox(height: 4),
          _buildRiskLegendItem(
            iconPath: 'lib/assets/map/landslide_3.png',
            label: 'Trung bình',
            value: '3-4',
          ),
          const SizedBox(height: 4),
          _buildRiskLegendItem(
            iconPath: 'lib/assets/map/landslide_4.png',
            label: 'Cao',
            value: '4-5',
          ),
          const SizedBox(height: 4),
          _buildRiskLegendItem(
            iconPath: 'lib/assets/map/landslide_5.png',
            label: 'Rất cao',
            value: '≥5',
          ),
        ],
      ),
    );
  }

  Widget _buildLineLegendItem({
    required Color color,
    required double width,
    required String label,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 16,
          child: Center(
            child: Container(
              width: 24,
              height: width,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRiskLegendItem({
    required String iconPath,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Image.asset(
            iconPath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                '($value)',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}