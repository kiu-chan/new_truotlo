import 'package:flutter/material.dart';

class MapLegend extends StatelessWidget {
  final Widget Function(String) buildRiskIcon;

  const MapLegend({
    super.key,
    required this.buildRiskIcon,
  });

  Widget buildAdministrativeLegendItem(String text, Color color, double thickness) {
    return Row(
      children: [
        Container(
          width: 24,
          height: thickness,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(thickness / 2),
          ),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget buildRiskLegendItem(String riskLevel, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: buildRiskIcon(riskLevel),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Chú giải bản đồ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.map, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ranh giới hành chính',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    buildAdministrativeLegendItem('Ranh giới tỉnh', Colors.pink, 3.0),
                    const SizedBox(height: 8),
                    buildAdministrativeLegendItem('Ranh giới huyện', Colors.black, 2.0),
                    const SizedBox(height: 8),
                    buildAdministrativeLegendItem('Ranh giới xã', Colors.grey, 1.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Mức độ nguy cơ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    buildRiskLegendItem('no_risk', 'Không có nguy cơ'),
                    buildRiskLegendItem('very_low', 'Rất thấp'),
                    buildRiskLegendItem('low', 'Thấp'),
                    buildRiskLegendItem('medium', 'Trung bình'),
                    buildRiskLegendItem('high', 'Cao'),
                    buildRiskLegendItem('very_high', 'Rất cao'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nhấn vào các điểm trên bản đồ để xem thông tin chi tiết về nguy cơ và thống kê.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}