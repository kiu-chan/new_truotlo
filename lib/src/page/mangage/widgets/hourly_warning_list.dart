// widgets/hourly_warning_list.dart
import 'package:flutter/material.dart';
import 'package:new_truotlo/src/data/manage/hourly_warning.dart';
import 'detail_row.dart';

class HourlyWarningList extends StatelessWidget {
  final List<HourlyWarning> hourlyWarnings;
  final Function(int) onDelete;

  const HourlyWarningList({
    Key? key,
    required this.hourlyWarnings,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hourlyWarnings.isEmpty) {
      return const Center(
        child: Text('Chưa có cảnh báo nào'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: hourlyWarnings.length,
      itemBuilder: (context, index) {
        final warning = hourlyWarnings[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              warning.formattedDate,
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
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        warning.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'Xem chi tiết',
                  onPressed: () => _showHourlyWarningDetails(context, warning),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Xóa',
                  onPressed: () => _deleteHourlyWarning(context, index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHourlyWarningDetails(BuildContext context, HourlyWarning warning) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cảnh báo ${warning.formattedDate}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DetailRow(label: 'Vị trí:', value: warning.location),
                DetailRow(label: 'Nguy cơ trượt nông:', value: warning.nguy_co_truot_nong),
                DetailRow(label: 'Nguy cơ lũ quét:', value: warning.nguy_co_lu_quet),
                DetailRow(label: 'Nguy cơ trượt lớn:', value: warning.nguy_co_truot_lon),
                DetailRow(label: 'Mô tả:', value: warning.description),
                DetailRow(label: 'Vĩ độ:', value: warning.lat.toString()),
                DetailRow(label: 'Kinh độ:', value: warning.lon.toString()),
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

  void _deleteHourlyWarning(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Bạn có chắc chắn muốn xóa cảnh báo này?'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                onDelete(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa cảnh báo'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
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