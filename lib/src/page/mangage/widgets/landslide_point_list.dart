// widgets/landslide_point_list.dart
import 'package:flutter/material.dart';
import 'package:new_truotlo/src/data/manage/landslide_point.dart';
import 'detail_row.dart';

class LandslidePointList extends StatelessWidget {
  final List<ManageLandslidePoint> landslidePoints;

  const LandslidePointList({
    Key? key,
    required this.landslidePoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (landslidePoints.isEmpty) {
      return const Center(
        child: Text('Chưa có điểm trượt lở nào'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: landslidePoints.length,
      itemBuilder: (context, index) {
        final point = landslidePoints[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              point.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.code, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Mã: ${point.code}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.blue),
              tooltip: 'Thông tin chi tiết',
              onPressed: () => _showLandslidePointDetails(context, point),
            ),
          ),
        );
      },
    );
  }

  void _showLandslidePointDetails(BuildContext context, ManageLandslidePoint point) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            point.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DetailRow(label: 'Mã:', value: point.code),
                DetailRow(label: 'Vĩ độ:', value: point.latitude.toString()),
                DetailRow(label: 'Kinh độ:', value: point.longitude.toString()),
                DetailRow(label: 'Mô tả:', value: point.description),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Đóng'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}