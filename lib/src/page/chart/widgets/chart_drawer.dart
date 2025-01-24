// lib/src/page/chart/widgets/chart_drawer.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartDrawerWidget extends StatelessWidget {
  final List<String> chartNames;
  final String selectedChart;
  final bool showLegend;
  final Function(String) onChartTypeChanged;
  final Function(bool) onShowLegendChanged;
  final bool isAdmin;
  final Function() onDateRangeSelect;
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  const ChartDrawerWidget({
    super.key,
    required this.chartNames,
    required this.selectedChart,
    required this.showLegend,
    required this.onChartTypeChanged,
    required this.onShowLegendChanged,
    required this.isAdmin,
    required this.onDateRangeSelect,
    this.startDateTime,
    this.endDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<String>> chartCategories = {
      'Đo nghiêng': chartNames.where((name) => name.startsWith('Đo nghiêng')).toList(),
      'Piezometer': chartNames.where((name) => name.startsWith('Piezometer')).toList(),
      'Crackmeter': chartNames.where((name) => name.startsWith('Crackmeter')).toList(),
      'Lượng mưa': chartNames.where((name) => name.contains('Lượng mưa')).toList(),
    };

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tùy chỉnh biểu đồ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onDateRangeSelect();
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _getDateRangeText(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...chartCategories.entries.map((category) {
                  if (category.value.isEmpty) return const SizedBox.shrink();
                  
                  return ExpansionTile(
                    leading: Icon(_getCategoryIcon(category.key)),
                    title: Text(
                      category.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Đã chọn: ${_getSelectedChartInCategory(category.value)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    children: category.value.map((chartName) {
                      return RadioListTile<String>(
                        title: Text(chartName),
                        value: chartName,
                        groupValue: selectedChart,
                        onChanged: (value) {
                          onChartTypeChanged(value!);
                        },
                      );
                    }).toList(),
                  );
                }),
                const Divider(),
                SwitchListTile(
                  title: const Text('Hiển thị chú thích'),
                  subtitle: const Text('Hiển thị thông tin chi tiết cho biểu đồ'),
                  secondary: const Icon(Icons.legend_toggle),
                  value: showLegend,
                  onChanged: onShowLegendChanged,
                ),
                if (!isAdmin)
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Chế độ xem hạn chế'),
                    subtitle: Text('Chỉ hiển thị dữ liệu 2 ngày gần nhất'),
                    dense: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeText() {
    if (startDateTime != null && endDateTime != null) {
      final startStr = DateFormat('dd/MM/yyyy HH:mm').format(startDateTime!);
      final endStr = DateFormat('dd/MM/yyyy HH:mm').format(endDateTime!);
      return 'Từ $startStr\nđến $endStr';
    }
    return 'Chọn khoảng thời gian';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Đo nghiêng':
        return Icons.compass_calibration;
      case 'Piezometer':
        return Icons.water;
      case 'Crackmeter':
        return Icons.water;
      case 'Lượng mưa':
        return Icons.water_drop;
      default:
        return Icons.show_chart;
    }
  }

  String _getSelectedChartInCategory(List<String> categoryCharts) {
    final selected = categoryCharts.where((chart) => chart == selectedChart);
    if (selected.isEmpty) return 'Chưa chọn';
    return selected.first.replaceAll(RegExp(r'^(Đo nghiêng|Piezometer|Crackmeter|Lượng mưa),?\s*'), '');
  }
}