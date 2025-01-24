// lib/src/page/chart/widgets/chart_body.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:new_truotlo/src/data/chart/chart_data.dart';
import 'package:new_truotlo/src/data/chart/landslide_data.dart';
import 'package:new_truotlo/src/page/chart/elements/chart_utils.dart';
import 'package:new_truotlo/src/page/map/widgets/map_loading.dart';

class ChartBody extends StatelessWidget {
 final bool isLoading;
 final String error;
 final Future<void> Function({bool showLoadingIndicator}) fetchData;
 final List<ChartData> chartDataList;
 final String selectedChart;
 final bool showLegend;
 final Map<int, bool> lineVisibility;
 final List<LandslideDataModel> filteredData;
 final bool isAdmin;
 final DateTime? startDateTime;
 final DateTime? endDateTime;
 final VoidCallback onDateRangeSelect;
 final Function(int) onToggleLineVisibility;

 const ChartBody({
   super.key,
   required this.isLoading,
   required this.error,
   required this.fetchData,
   required this.chartDataList,
   required this.selectedChart,
   required this.showLegend,
   required this.lineVisibility,
   required this.filteredData,
   required this.isAdmin,
   required this.startDateTime,
   required this.endDateTime,
   required this.onDateRangeSelect,
   required this.onToggleLineVisibility,
 });

 @override
 Widget build(BuildContext context) {
   if (isLoading) {
     return const Center(child: LoadingScreen());
   }

   if (error.isNotEmpty) {
     return _buildErrorWidget(context);
   }

   return RefreshIndicator(
     onRefresh: () => fetchData(showLoadingIndicator: false),
     child: SingleChildScrollView(
       physics: const AlwaysScrollableScrollPhysics(),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           _buildHeader(context),
           if (chartDataList.isEmpty)
             _buildNoDataWidget(context)
           else  
             _buildChartContent(),
         ],
       ),
     ),
   );
 }

 Widget _buildHeader(BuildContext context) {
   return Padding(
     padding: const EdgeInsets.all(16.0),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Expanded(
               child: Text(
                 selectedChart,
                 style: const TextStyle(
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
               ),
             ),
             if (isAdmin || selectedChart.contains('Lượng mưa'))
               IconButton(
                 icon: const Icon(Icons.date_range),
                 onPressed: onDateRangeSelect,
                 tooltip: 'Chọn khoảng thời gian',
               ),
           ],
         ),
         const SizedBox(height: 8),
         Text(
           _getDateRangeDisplayText(),
           style: TextStyle(
             fontSize: 14,
             color: Colors.grey[600],
             fontStyle: FontStyle.italic,
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildChartContent() {
   if (selectedChart == 'Đo nghiêng') {
     return Column(
       children: [
         _buildSingleChart('Đo nghiêng, hướng Tây - Đông'),
         const SizedBox(height: 20),
         _buildSingleChart('Đo nghiêng, hướng Bắc - Nam'),
       ],
     );
   } else {
     return _buildSingleChart(selectedChart);
   }
 }

 String _getDateRangeDisplayText() {
   if (startDateTime != null && endDateTime != null) {
     final startStr = DateFormat('dd/MM/yyyy HH:mm').format(startDateTime!);
     final endStr = DateFormat('dd/MM/yyyy HH:mm').format(endDateTime!);
     return 'Từ $startStr đến $endStr';
   } else if (!isAdmin) {
     return 'Dữ liệu của 2 ngày gần nhất';
   }
   return 'Tất cả dữ liệu';
 }

 Widget _buildSingleChart(String chartName) {
   final ChartData chartData = chartDataList.firstWhere((chart) => chart.name == chartName);
   final bool isRainfallChart = chartName.contains('Lượng mưa');
   
   return Column(
     children: [
       Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0),
         child: Text(
           chartName,
           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
           textAlign: TextAlign.center,
         ),
       ),
       const SizedBox(height: 10),
       AspectRatio(
         aspectRatio: chartName.contains('Lượng mưa') ? 2.0 : 1.5,
         child: LineChart(
           ChartUtils.getLineChartData(
             chartName,
             chartDataList,
             lineVisibility,
             filteredData,
             isAdmin,
           ),
         ),
       ),
       if (isRainfallChart) ...[
         const SizedBox(height: 10),
         _buildRainfallSummaryCard(chartData),
       ],
       if (showLegend) ...[
         const SizedBox(height: 20),
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16.0),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text(
                 'Chú thích:',
                 style: TextStyle(fontWeight: FontWeight.bold),
               ),
               const SizedBox(height: 10),
               SizedBox(
                 height: 200,
                 child: SingleChildScrollView(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: ChartUtils.buildLegendItems(
                       chartName,
                       lineVisibility,
                       chartDataList, 
                       onToggleLineVisibility,
                       isAdmin,
                     ),
                   ),
                 ),
               ),
             ],
           ),
         ),
       ],
     ],
   );
 }

 Widget _buildRainfallSummaryCard(ChartData chartData) {
   if (!chartData.name.contains('Lượng mưa')) return const SizedBox.shrink();

   final bool isCumulative = chartData.name == 'Lượng mưa tích lũy';
   final Color cardColor = isCumulative ? Colors.green.shade50 : Colors.blue.shade50;
   final Color textColor = isCumulative ? Colors.green : Colors.blue;

   return Card(
     color: cardColor,
     margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
     child: Padding(
       padding: const EdgeInsets.all(16.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             children: [
               Icon(Icons.water_drop, color: textColor),
               const SizedBox(width: 8),
               Text(
                 'Thống kê lượng mưa',
                 style: TextStyle(
                   fontSize: 18,
                   fontWeight: FontWeight.bold,
                   color: textColor,
                 ),
               ),
             ],
           ),
           const SizedBox(height: 12),
           Text(
             _getRainfallSummary(chartData),
             style: TextStyle(
               fontSize: 16,
               color: textColor,
             ),
           ),
           if (isCumulative) ...[
             const SizedBox(height: 8),
             const Divider(),
             Text(
               'Thời gian bắt đầu: ${DateFormat('dd/MM/yyyy HH:mm').format(chartData.dates.first)}',
               style: const TextStyle(fontSize: 14),
             ),
             Text(
               'Thời gian kết thúc: ${DateFormat('dd/MM/yyyy HH:mm').format(chartData.dates.last)}',
               style: const TextStyle(fontSize: 14),
             ),
           ],
         ],
       ),
     ),
   );
 }

 String _getRainfallSummary(ChartData chartData) {
   if (chartData.name == 'Lượng mưa tích lũy') {
     final totalRainfall = chartData.dataPoints[0].last;
     final duration = chartData.dates.last.difference(chartData.dates.first);
     final days = duration.inDays;
     final hours = duration.inHours % 24;
     
     String durationText = '';
     if (days > 0) {
       durationText += '$days ngày ';
     }
     if (hours > 0 || days == 0) {
       durationText += '$hours giờ';
     }
     
     return 'Tổng lượng mưa: ${totalRainfall.toStringAsFixed(1)} mm trong $durationText';
   } else if (chartData.name == 'Lượng mưa') {
     final maxRainfall = chartData.dataPoints[0].reduce((max, value) => max > value ? max : value);
     final maxRainfallTime = chartData.dates[
       chartData.dataPoints[0].indexOf(maxRainfall)
     ];
     
     return 'Lượng mưa cao nhất: ${maxRainfall.toStringAsFixed(1)} mm (${DateFormat('dd/MM/yyyy HH:mm').format(maxRainfallTime)})';
   }
   return '';
 }

 Widget _buildErrorWidget(BuildContext context) {
   return Center(
     child: Padding(
       padding: const EdgeInsets.all(16.0),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Icon(
             Icons.error_outline,
             size: 48,
             color: Colors.red[300],
           ),
           const SizedBox(height: 16),
           Text(
             error,
             textAlign: TextAlign.center,
             style: const TextStyle(
               fontSize: 16,
               color: Colors.red,
             ),
           ),
           const SizedBox(height: 16),
           ElevatedButton.icon(
             onPressed: () => fetchData(showLoadingIndicator: true),
             icon: const Icon(Icons.refresh),
             label: const Text('Thử lại'),
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.blue,
               foregroundColor: Colors.white,
               padding: const EdgeInsets.symmetric(
                 horizontal: 20,
                 vertical: 12,
               ),
             ),
           ),
         ],
       ),
     ),
   );
 }

 Widget _buildNoDataWidget(BuildContext context) {
   return Center(
     child: Padding(
       padding: const EdgeInsets.all(16.0),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Icon(
             Icons.info_outline,
             size: 48,
             color: Colors.blue[300],
           ),
           const SizedBox(height: 16),
           const Text(
             'Không có dữ liệu trong khoảng thời gian đã chọn',
             textAlign: TextAlign.center,
             style: TextStyle(fontSize: 16),
           ),
           if (startDateTime != null && endDateTime != null) ...[
             const SizedBox(height: 16),
             ElevatedButton.icon(
               onPressed: onDateRangeSelect,
               icon: const Icon(Icons.date_range),
               label: const Text('Chọn khoảng thời gian khác'),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.blue,
                 foregroundColor: Colors.white,
                 padding: const EdgeInsets.symmetric(
                   horizontal: 20,
                   vertical: 12,
                 ),
               ),
             ),
           ],
         ],
       ),
     ),
   );
 }
}