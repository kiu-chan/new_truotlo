// widgets/forecast_list.dart
import 'package:flutter/material.dart';
import 'package:new_truotlo/src/data/manage/forecast.dart';
import 'package:new_truotlo/src/database/database.dart';
import 'detail_row.dart';

class ForecastList extends StatelessWidget {
  final List<Forecast> forecasts;
  final DefaultDatabase database;
  final Function(int) onDelete;

  const ForecastList({
    Key? key,
    required this.forecasts,
    required this.database,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) {
      return const Center(
        child: Text('Chưa có dự báo nào'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: forecasts.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              forecasts[index].name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'Xem chi tiết',
                  onPressed: () => _showForecastDetails(context, forecasts[index].id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showForecastDetails(BuildContext context, int forecastId) async {
    try {
      final detail = await database.landslideDatabase.fetchForecastDetail(forecastId);

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Chi tiết dự báo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DetailRow(label: 'Tên điểm:', value: detail.tenDiem),
                  DetailRow(label: 'Vị trí:', value: detail.viTri),
                  DetailRow(label: 'Kinh độ:', value: detail.kinhDo as String),
                  DetailRow(label: 'Vĩ độ:', value: detail.viDo as String),
                  DetailRow(label: 'Tỉnh:', value: detail.tinh),
                  DetailRow(label: 'Huyện:', value: detail.huyen),
                  DetailRow(label: 'Xã:', value: detail.xa),
                  const SizedBox(height: 16),
                  const Text(
                    'Dự báo các ngày:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...detail.days.map((day) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Ngày ${day.day} (${day.date.day}/${day.date.month}/${day.date.year}) - Nguy cơ: ${day.riskLevel}',
                    ),
                  )),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải chi tiết dự báo: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}